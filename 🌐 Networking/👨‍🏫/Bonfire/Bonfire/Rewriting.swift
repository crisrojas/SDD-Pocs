//
//  Rewriting.swift
//  Bonfire
//
//  Created by Cristian Felipe Patiño Rojas on 21/12/2023.
//

import Foundation
import Combine

struct Response<T: Decodable>: Decodable {
    let data: T
}

enum AsyncState<T> {
    case loading(cachedData: T? = nil)
    case success(T)
    case error(String)
    
    var data: T? {
        switch self {
        case .success(let data): return data
        case .loading(let data): return data
        case .error: return nil
        }
    }
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    func toLoading() -> Self {
        switch self {
        case .loading: return self
        case .success(let data): return .loading(cachedData: data)
        case .error: return .loading(cachedData: nil)
        }
    }
}

protocol Service_Bis {
    static var mods: [String: (inout URLRequest) -> Void] {get set}
    var baseURL: String {get set}
    func config(_ pat: String, _ mod: @escaping (inout URLRequest) -> Void)
    func decorated(_ absURL: String, _ req: URLRequest) -> URLRequest
    func match(_ pat: String, _ absURL: String) -> Bool
    func makeRequest(_ relativeURL: String) -> URLRequest
}

extension Service_Bis {
    
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


protocol Resource_Bis: ObservableObject {
    
    associatedtype ResourceType: Decodable
    
    static var service: Service_Bis {get}

    var cancellable: AnyCancellable? {get set}
    
    var url: String {get set}
    
    var state: AsyncState<ResourceType> {get set}
    
    var urlRequestBase: URLRequest {get}
    var contentType: String {get}
    
    func load() -> Callback<ResourceType>
    func load(using: Request<ResourceType>) -> Callback<ResourceType>
    
    func request(_ method: HttpMethod, _ payload: HttpBody?) -> Request<ResourceType>
    func chained(_ req: Request<ResourceType>) -> Request<ResourceType>
}

extension Resource_Bis {
    
    var mods: [String: (Request<ResourceType>) -> Request<ResourceType>] {[:]}
    
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
            
            guard let decoded = try? jsonDecoder.decode(Response<ResourceType>.self, from: data) else {
                throw NetError.decodeError
            }
            
            return (decoded.data, resp)
        }.eraseToAnyPublisher()
    }
    
    @discardableResult
    func load(using req: Request<ResourceType>) -> Callback<ResourceType> {
        let cb = Callback<ResourceType>()
        cancellable = req.receive(on: RunLoop.main).sink(receiveCompletion: { [weak self] (completion) in
            guard let self else { return }
            switch completion {
            case .finished:
                cb.completion?()
            case .failure(let e):
                self.state = .error(e.localizedDescription)
                cb.failure?(e)
            }
        }) { (data, resp) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.state = .success(data)
            }
            cb.success?(data)
        }
        return cb
    }
    
    @discardableResult
    public func load() -> Callback<ResourceType> {
        state = state.toLoading()
        return load(using: request(.get))
    }
    
    func chained(_ req: Request<ResourceType>) -> Request<ResourceType> {
        req
    }
}


fileprivate var jsonDecoder: JSONDecoder = {
  let d = JSONDecoder()
    // wont working because we aren't mapping to "name" instead of "employeeName".
    // keyDecodingStrategy = .convertFromSnakeCase
    return d
}()

typealias Employees = [Employee]
final class EmployeesResource: Resource_Bis, ObservableObject {
    @Published var state: AsyncState<Employees> = .loading()
    var cancellable: AnyCancellable?
    var url: String = "employees"
    var contentType = "application/json"
}

/// On importer module:
public final class API_Bis: Service_Bis {
    static var mods = [String : (inout URLRequest) -> Void]()
    var baseURL = "https://crisrojas.github.io/dummyjson/api/v1/"
    static let shared = API_Bis()
    lazy var employees = EmployeesResource()
}

extension Resource_Bis {
    static var service: Service_Bis { API_Bis.shared }
}
