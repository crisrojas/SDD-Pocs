//
//  File.swift
//  PlaygroundsTests
//
//  Created by Cristian Patiño Rojas on 19/11/23.
//

import Foundation

import SwiftUI
import Combine

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


final class API: Service {
    static var mods = [String : (inout URLRequest) -> Void]()
    var baseURL = "http://dummy.restapiexample.com/api/v1/"
    let employes = JSON("employees")
}

enum HttpMethod: String {
    case get, post, put, delete
}

protocol HttpBody {
    var body: Data? {get}
}

protocol NetData {
    init()
    static func decode(_ data: Data) -> Self?
}

typealias Request<T> = AnyPublisher<(T, HTTPURLResponse), Error>

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
        let req = Self.service.decorated(r.url?.absoluteString ?? "",  r)
        return URLSession.shared.dataTaskPublisher(for: req).tryMap {
            (data, response) in
            guard let resp = response as? HTTPURLResponse, 200 ..< 300 ~= resp.statusCode else {
                throw NetError.errorResponse
            }
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
    func load() -> Callback<ResourceType> {
        load(using: request(.get))
    }
    
    func config(_ pat: String, _ mod: @escaping (Request<ResourceType>) -> Request<ResourceType>) {
        Self.mods[pat] = mod
    }
    
    func chained(_ req: Request<ResourceType>) -> Request<ResourceType> {
        req
    }
}

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


typealias P = Params
enum Params: String, Codable {
    case none, full_name, url, items, test
}


struct MJ: ExpressibleByDictionaryLiteral, CustomStringConvertible, HttpBody, NetData  {
    var body: Data?
    
    init() {}
    
    static func decode(_ data: Data) -> MJ? {
        nil
    }
    
    var d = [String: Any]()
    var description: String {
        return d.description
    }
    init(dictionaryLiteral elements: (Params, Any)...) {
        var pj = [Params: Any]()
        for (k, v) in elements {
            pj[k] = v
        }
        d = pj.toStringKey()
    }
    
    static func raw(_ string: String) -> Self { .init() }
}

extension Dictionary where Key == Params {
    func toStringKey() -> [String: Any] {
        var d = [String: Any]()
        for k in self.keys {
            if let u = self[k] as? [Params: Any] {
                d[k.rawValue] = u.toStringKey()
                continue
            }
            d[k.rawValue] = self[k]
        }
        return d
    }
}


final class JSON: Resource {
    
    var cancellable: AnyCancellable?
    
    static var mods = [String : (Request<MJ>) -> Request<MJ>]()
    
    var url: String
    
    var error: Error?
    
    var response: HTTPURLResponse?
    
    var contentType = "application/json"
    
    @Published var firstName = ""
    @Published var data = MJ.raw("test") {
        didSet {
//            print(data[0])
            firstName = "hello world"
        }
    }

    init(_ relURL: String) {
        url = relURL
    }
}


let api = API()

enum test_bonfire {
    struct MyView: View {
        @ObservedObject var resource = api.employes
        var body: some View {
            Text(resource.firstName)
                .onAppear {
                    resource.load()
                }
        }
    }
}
