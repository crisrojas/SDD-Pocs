//
//  Bonfire.swift
//  Bonfire
//
//  Created by Cristian Felipe Patiño Rojas on 02/12/2023.
//
import Foundation
import Combine

// https://github.com/jimlai586/Bonfire/blob/master/README.md
protocol Service {
    static var mods: [String: (inout URLRequest) -> Void] {get set}
    var baseURL: String {get set}
    func config(_ pat: String, _ mod: @escaping (inout URLRequest) -> Void)
    func decorated(_ absURL: String, _ req: URLRequest) -> URLRequest
    func match(_ pat: String, _ absURL: String) -> Bool
    func makeRequest(_ relativeURL: String) -> URLRequest
}

extension Service {
    
    func config(_ pat: String, _ mod: @escaping (inout URLRequest) -> Void) {
        Self.mods[pat] = mod
    }
    
    func decorated(_ absURL: String, _ req: URLRequest) -> URLRequest {
        Array(Self.mods.keys).reduce(into: req) { (result, pat) in
            guard match(pat, absURL), let mod = Self.mods[pat] else {return}
            mod(&result)
        }
    }
    
    func match(_ pat: String, _ absURL: String) -> Bool {
        true
    }

    func makeRequest(_ relativeURL: String) -> URLRequest {
        let absURL = baseURL + relativeURL
        return URLRequest(url: URL(string: absURL)!)
    }
}

public final class API: Service {
    static var mods = [String : (inout URLRequest) -> Void]()
    var baseURL = "https://crisrojas.github.io/dummyjson/api/v1/"
    let employees = EmployeesMJ()
    let employeesCodable = EmployeesCodable()
    let jsonEmployees = JSON("employees")
}

enum HttpMethod: String {
    case get, post, put, delete
}

protocol HttpBody {
    var body: Data? {get}
}

protocol NetData {
//    init()
    static func decode(_ data: Data) -> Self?
}


/// Parece que hay dos estrategias de networking:
/// 1. Orientada a request. Ej. moya
/// 2. Orientada a recursos. Ej. protocol-oriented networking de M. Manferdini
/// Este enfoque de Jim lai, parece corresponder a la segunda estrategia
protocol Resource: ObservableObject {
    
    /// Un recurso tiene un tipo asociado
    /// Ese tipo sabe como construirse a partir de data
    associatedtype ResourceType: NetData
    
    /// Ni idea de qué es esto:
    static var mods: [String: (Request<ResourceType>) -> Request<ResourceType>] {get set}
    
    /// El recurso tiene una dependencia a un servicio.
    /// Esto permite implementar lógica de fetch en el propio servicio
    static var service: Service {get}

    /// Dependencia a cancellable. Imagino que para poder usar combine para notificar a los observadores
    var cancellable: AnyCancellable? {get set}
    
    /// El recurso tiene una url. Imagino que corresponde al endpoint al que se va a llamar.
    /// Lo que no se es como se pasan parámetros de url/headers etc...
    var url: String {get set}
    
    /// La data del recurso. Creo que podría ser opcional en un principio
    var data: ResourceType {get set}
    
    /// Error, en caso de error en la respuesta
    var error: Error? {get set}
    var response: HTTPURLResponse? {get set}
    
    /// Tal vez aquí se construya la url
    var urlRequestBase: URLRequest {get}
    var contentType: String {get}
    
    /// Función que carga el recurso.
    /// Devuelve un callback que es un tipo custom que parece una promesa.
    func load() -> Callback<ResourceType>
    func load(using: Request<ResourceType>) -> Callback<ResourceType>
    
    func request(_ method: HttpMethod, _ payload: HttpBody?) -> Request<ResourceType>
    func config(_ pat: String, _ mod: @escaping (Request<ResourceType>) -> Request<ResourceType>)
    func chained(_ req: Request<ResourceType>) -> Request<ResourceType>
}

/// Lógica por defecto
extension Resource {
    
    static var service: Service { API() }
    
    var urlRequestBase: URLRequest {
        var r = Self.service.makeRequest(url)
        r.addValue(contentType, forHTTPHeaderField: "Content-Type")
        return r
    }
    
    func request(_ method: HttpMethod = .post, _ payload: HttpBody? = nil) -> Request<ResourceType> {
        var r = urlRequestBase
        r.httpMethod = method.rawValue.capitalized
        r.httpBody = payload?.body
        
        /// @question: Example usage of mods appended through the decorated method on service?
        let req = Self.service.decorated(r.url?.absoluteString ?? "",  r)
        return URLSession.shared.dataTaskPublisher(for: req).tryMap {
            (data, response) in
            guard let resp = response as? HTTPURLResponse, 200 ..< 300 ~= resp.statusCode else {
                throw NetError.errorResponse
            }
            
            /// @question: Why not using decodable directly ?
            /// Guess we use NetData protocol so we can have the flexibility for use MagicJSON if wanted
            guard let d = ResourceType.decode(data) else {
                throw NetError.decodeError
            }
            return (d, resp)
        }.eraseToAnyPublisher()
    }
    
    @discardableResult
    func load(using req: Request<ResourceType>) -> Callback<ResourceType> {
        let cb = Callback<ResourceType>()
        cancellable = req.receive(on: RunLoop.main).sink(receiveCompletion: { (completion) in
            switch completion {
            case .finished:
                cb.completion?()
            case .failure(let e):
                self.error = e
                cb.failure?(e)
            }
        }) { (data, resp) in
            self.data = data
            self.response = resp
            cb.success?(data)
        }
        return cb
    }
    @discardableResult
    public func load() -> Callback<ResourceType> {
        load(using: request(.get))
    }
    func config(_ pat: String, _ mod: @escaping (Request<ResourceType>) -> Request<ResourceType>) {
        Self.mods[pat] = mod
    }
    func chained(_ req: Request<ResourceType>) -> Request<ResourceType> {
        req
    }
}

/// @question: couldn't we just have two callbacks:
/// onSuccess & onFailure and return Self so we can handle both cases?
/// Something like
/// myResource.load().onSucesss { _ in }.onFailure { print("failed") }
/// Isn't that necessary to handle both cases?
/// Or maybe we could just have the state in resource itself published so view can listen and act,
/// that way we could havbe only the "completiion" callback and remove the onSuccess & onFailure ones
final class Callback<T> {
    var completion: (() -> Void)?
    var success: ((T) -> Void)?
    var failure: ((Error) -> Void)?
    func onCompletion(_ cls: @escaping () -> Void) {
        completion = cls
    }
    func onSuccess(_ cls: @escaping (T) -> Void) {
        success = cls
    }
    func onFailure(_ cls: @escaping (Error) -> Void) {
        failure = cls
    }
}

enum NetError: Error {
    case errorResponse, decodeError
}

typealias Request<T> = AnyPublisher<(T, HTTPURLResponse), Error>

fileprivate var jsonDecoder: JSONDecoder = {
  let d = JSONDecoder()
    // wont working because we aren't mapping to "name" instead of "employeeName".
    // keyDecodingStrategy = .convertFromSnakeCase
    return d
}()

extension Decodable {
    static func decode(_ data: Data) -> Self? {
        try? jsonDecoder.decode(Self.self, from: data)
    }
}


public protocol Initable {init()}
