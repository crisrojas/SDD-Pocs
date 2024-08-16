import SwiftUI
import Combine




let jsonEncoder = JSONEncoder()
let jsonDecoder = JSONDecoder()

enum Environment {
    case localhost(Int = 9000)
    case custom(String = "http://phpgrounds.test/jwt")
    
    var baseURL: URL! {
        switch self {
        case .localhost(let port): return URL(string: "http://localhost:\(port)")
        case .custom(let path): return URL(string: path)
        }
    }
}




final class API: Service {
    static var mods: [String : (inout URLRequest) -> Void] = [
        "authorization": appendAccessToken
    ]
    
    static func appendAccessToken(to request: inout URLRequest) {
        guard let accessToken = UserDefaults.standard.string(forKey: "accessToken") else { return }
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    }
    
    var environment = Environment.custom("http://127.0.0.1:8000")
    static let shared = API()
    private init() {}
    lazy var baseURL = environment.baseURL.absoluteString
    let but = JSON("employees")
    let recipes = JSON("recipes")
}


func login(email: String, password: String) async throws -> AuthToken {
    let authCommand = AuthCommand(email: email, password: password)
    let body = try jsonEncoder.encode(authCommand)
    let url = API.shared.environment.baseURL!.appendingPathComponent("login")
    var request = URLRequest(url: url)
    request.httpMethod = "post"
    request.httpBody = body
    let (data, _) = try await URLSession.shared.data(for: request)
    let authToken = try jsonDecoder.decode(AuthToken.self, from: data)
    return authToken
}




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
        let absURL = URL(string: baseURL)!.appendingPathComponent(relativeURL)
        return URLRequest(url: absURL)
    }
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

extension Data {
    func string() -> String {
        String(decoding: self, as: UTF8.self)
    }
}

typealias Request<T> = AnyPublisher<(T, HTTPURLResponse), Error>

protocol Resource: ObservableObject {
    associatedtype ResourceType: NetData
    static var mods: [String: (Request<ResourceType>) -> Request<ResourceType>] {get set}
    static var service: Service {get}
    var cancellable: AnyCancellable? {get set}
    var url: String {get set}
    var state: ViewState<ResourceType> {get set}
//    var error: Error? {get set}
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
    static var service: Service { API.shared }
    
    var urlRequestBase: URLRequest {
        var r = Self.service.makeRequest(url)
        r.addValue(contentType, forHTTPHeaderField: "Content-Type")
        return r
    }
    @discardableResult
    func request(_ method: HttpMethod = .post, _ payload: HttpBody? = nil) -> Request<ResourceType> {
        var r = urlRequestBase
        r.httpMethod = method.rawValue.capitalized
        r.httpBody = payload?.body
        let req = Self.service.decorated(r.url?.absoluteString ?? "",  r)
        return URLSession.shared.dataTaskPublisher(for: req).tryMap {
            (data, response) in
            guard let resp = response as? HTTPURLResponse else {
                throw NetError.errorResponse
            }
            
            guard 200 ..< 300 ~= resp.statusCode else {
                if resp.statusCode == 401 {
                    userSettings.isLoggedIn = false
                    throw NetError.unauthorized
                }
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
//                self.error = e
                self.state = .error(e.localizedDescription)
                cb.failure?(e)
            }
        }) { (data, resp) in
            self.state = .success(data)
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
    case unauthorized
    case errorResponse
    case decodeError
}

extension MJ: HttpBody, NetData {
    static func decode(_ data: Data) -> MJ? {
        MJ(data: data)
    }
    
    var body: Data? {
        self.data
    }
}

final class JSON: Resource {
    
    var cancellable: AnyCancellable?
    
    static var mods = [String : (Request<MJ>) -> Request<MJ>]()
    
    var url: String
    
    var error: Error?
    
    var response: HTTPURLResponse?
    
    var contentType = "application/json"
    
//    @Published var data: MJ?
    @Published var state = ViewState<MJ>.idle
    
    init(_ relURL: String) {
        url = relURL
    }
}

