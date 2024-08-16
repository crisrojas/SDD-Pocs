//
//  Bonfire.swift
//  Bonfire
//
//  Created by Cristian Felipe Patiño Rojas on 02/12/2023.
//

import Foundation

//
//  Bonfire.swift
//  Networking
//
//  Created by Cristian Felipe Patiño Rojas on 02/12/2023.
//

import Combine

// https://github.com/jimlai586/Bonfire/blob/master/README.md
public protocol Service {
    static var mods: [String: (inout URLRequest) -> Void] {get set}
    var baseURL: String {get set}
    func config(_ pat: String, _ mod: @escaping (inout URLRequest) -> Void)
    func decorated(_ absURL: String, _ req: URLRequest) -> URLRequest
    func match(_ pat: String, _ absURL: String) -> Bool
    func makeRequest(_ relativeURL: String) -> URLRequest
}

extension Service {
    public func config(_ pat: String, _ mod: @escaping (inout URLRequest) -> Void) {
        Self.mods[pat] = mod
    }
    public func decorated(_ absURL: String, _ req: URLRequest) -> URLRequest {
        Array(Self.mods.keys).reduce(into: req) { (result, pat) in
            guard match(pat, absURL), let mod = Self.mods[pat] else {return}
            mod(&result)
        }
    }
    public func match(_ pat: String, _ absURL: String) -> Bool {
        true
    }

   public func makeRequest(_ relativeURL: String) -> URLRequest {
        let absURL = baseURL + relativeURL
        return URLRequest(url: URL(string: absURL)!)
    }
}


public enum HttpMethod: String {
    case get, post, put, patch, delete
}

public protocol HttpBody {
    var body: Data? {get}
}

public protocol NetData {
    static func decode(_ data: Data) -> Self?
}

public typealias Request<T> = AnyPublisher<(T, HTTPURLResponse), Error>

public protocol Resource: ObservableObject {
    associatedtype ResourceType: NetData
    static var mods: [String: (Request<ResourceType>) -> Request<ResourceType>] {get set}
    static var service: Service {get}
    var cancellable: AnyCancellable? {get set}
    var url: String {get set}
    var data: ResourceType {get set}
    var error: Error? {get set}
    var response: HTTPURLResponse? {get set}
    var urlRequestBase: URLRequest {get}
    var contentType: String {get}
    func load() -> Callback<ResourceType>
    func load(using: Request<ResourceType>) -> Callback<ResourceType>
    func request(_ method: HttpMethod, _ payload: HttpBody?) -> Request<ResourceType>
    func config(_ pat: String, _ mod: @escaping (Request<ResourceType>) -> Request<ResourceType>)
    func chained(_ req: Request<ResourceType>) -> Request<ResourceType>
}

extension Resource {
    
    /// @question: Why having a default value for this?
    /// If we want to move this logic to a common reusable library, wouldn't that mean that the Resource is coupled to a concrete implementation?
    /// Nope -> I think this static can be removed if moved in a library and added on the importer module through protocol extension.
    /// Still, that would make the Resource only work with a data api, if we have more than one api in the app I believe we should modifiy this to not be a static
    /// so it can be passed to a given resource on instantiation/configuration (through property override)
//    public static var service: Service {
//        API()
//    }
    public var urlRequestBase: URLRequest {
        var r = Self.service.makeRequest(url)
        r.addValue(contentType, forHTTPHeaderField: "Content-Type")
        return r
    }
    
    public func request(_ method: HttpMethod = .post, _ payload: HttpBody? = nil) -> Request<ResourceType> {
        var r = urlRequestBase
        r.httpMethod = method.rawValue.capitalized
        r.httpBody   = payload?.body
        
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
    public func load(using req: Request<ResourceType>) -> Callback<ResourceType> {
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
    public func config(_ pat: String, _ mod: @escaping (Request<ResourceType>) -> Request<ResourceType>) {
        Self.mods[pat] = mod
    }
    
    /// @question: how is this used? is this for chainig requests?
    public func chained(_ req: Request<ResourceType>) -> Request<ResourceType> {
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
public final class Callback<T> {
    var completion: (() -> Void)?
    var success: ((T) -> Void)?
    var failure: ((Error) -> Void)?
    public func onCompletion(_ cls: @escaping () -> Void) {
        completion = cls
    }
    public func onSuccess(_ cls: @escaping (T) -> Void) {
        success = cls
    }
    public func onFailure(_ cls: @escaping (Error) -> Void) {
        failure = cls
    }
}

enum NetError: Error {
    case errorResponse, decodeError
}




extension Decodable {
    public static func decode(_ data: Data) -> Self? {
        try? jsonDecoder.decode(Self.self, from: data)
    }
}


extension Wrapper: NetData {}

typealias AppRequest<T: Codable> = Request<Wrapper<T>>

