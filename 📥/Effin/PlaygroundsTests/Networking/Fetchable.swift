////
////  Fetchable.swift
////  Effin
////
////  Created by Cristian Patiño Rojas on 15/11/23.
////
//
//import Foundation
//
//enum ApiPaths {
//    case orders
//    case order(id: Int)
//    // ...
//    var value: String {
//        switch self {
//        case .order(let id): return "/order/\(id)"
//        default: return "/" + String(describing: self)
//        }
//    }
//}
//
//fileprivate struct ResourceExample {
//    let path: String
//}
//
//extension ResourceExample {
//    init(path: ApiPaths) {
//        self.path = path.value
//    }
//}
//
//fileprivate let res = ResourceExample(path: .order(id: 1))
//
//// As described here: https://betterprogramming.pub/async-await-generic-network-layer-with-swift-5-5-2bdd51224ea9
//enum RequestMethod: String {
//    case delete = "DELETE"
//    case get = "GET"
//    case patch = "PATCH"
//    case post = "POST"
//    case put = "PUT"
//}
//
//enum RequestError: Error {
//    case decode
//    case invalidURL
//    case noResponse
//    case unauthorized
//    case unexpectedStatusCode
//    case unknown
//    
//    var customMessage: String {
//        switch self {
//        case .decode:
//            return "Decode error"
//        case .unauthorized:
//            return "Session expired"
//        default:
//            return "Unknown error"
//        }
//    }
//}
//
//protocol Endpoint {
//    var scheme: String { get }
//    var host: String { get }
//    var path: String { get }
//    var method: RequestMethod { get }
//    var header: [String: String]? { get }
//    var body: [String: String]? { get }
//    func get() async throws -> Data
//}
//
//extension Endpoint {
//    var scheme: String {""}
//    var host: String {""}
//    var path: String {""}
//    var method: RequestMethod {.get}
//    var header: [String : String]? {[:]}
//    var body: [String : String]? {[:]}
//}
//
//protocol Fetchable: Identifiable, Decodable {
//    static var allEndpoint: Endpoint { get }
//    static func standaloneEndpoint(id: Self.ID) -> Endpoint
//}
//
//extension Fetchable {
//    static func getAll() async throws -> [Self] {
//        let data = try await allEndpoint.get()
//        let decoded = try JSONDecoder().decode([Self].self, from: data)
//        return decoded
//    }
//    
//    static func get(id: Self.ID) async throws -> Self {
//        let data = try await standaloneEndpoint(id: id).get()
//        let decoded = try JSONDecoder().decode(Self.self, from: data)
//        return decoded
//    }
//}
//
//enum UserEndpoint: Endpoint {
//    case all
//    case standalone(id: UUID)
//    
//    var scheme: String { "" }
//    var host: String { "" }
//    var path: String { "" }
//    var method: RequestMethod { .get }
//    var header: [String : String]? { [:] }
//    var body: [String : String]? { [: ]}
//    
//    func get() async throws -> Data {
//        Data("getted data".utf8)
//    }
//}
//
//struct ApiUser: Fetchable {
//    let id: UUID
//    static var allEndpoint: Endpoint { UserEndpoint.all }
//    static func standaloneEndpoint(id: UUID) -> Endpoint { UserEndpoint.standalone(id: id) }
//}
//
///// Ventajas de este métodología:
///// No tenemos que recordar qué repositorio recupera qué entidad. Simplemente recuperamos la entidad que queremos y listo.
///// ¿Puede reducir completamente la necesidad de un objeto "Service"?
//fileprivate func main() async throws {
//    let _ = try await ApiUser.getAll()
//    let _ = try await ApiUser.get(id: UUID())
//}
//
///// Inconvenientes: No escala, habrá veces en las que una lista de entidades sea devuelta a partir de varios endpoints: ¿Qué pasa si tenemos el caso siguiente?;
//enum MoviesEndpoint {
//    case topRated
//    case popular
//    case upcoming
//    case standalone(id: Int)
//}
//
///// Tal vez podamos solucionarlo hacinedo usando al propio Endpoint:
//
//protocol EndpointBis {
//    associatedtype T: Decodable
//    var scheme: String { get }
//    var host: String { get }
//    var path: String { get }
//    var method: RequestMethod { get }
//    var header: [String: String]? { get }
//    var body: [String: String]? { get }
//    func getData() async throws -> Data
//    func get() async throws -> T
//}
//
//extension EndpointBis {
//    var scheme: String {""}
//    var host: String {""}
//    var path: String {""}
//    var method: RequestMethod {.get}
//    var header: [String : String]? {[:]}
//    var body: [String : String]? {[:]}
//    
//    func getData() async throws -> Data {
//        var urlComponents = URLComponents()
//        urlComponents.scheme = scheme
//        urlComponents.host = host
//        urlComponents.path = path
//        
//        guard let url = urlComponents.url else {
//            throw RequestError.invalidURL
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = method.rawValue
//        request.allHTTPHeaderFields = header
//        
//        if let body = body {
//            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
//        }
//        
//        let (data, response) = try await URLSession.shared.data(for: request, delegate: nil)
//        guard let response = response as? HTTPURLResponse else {
//            throw RequestError.noResponse
//        }
//        switch response.statusCode {
//        case 200...299:
//            return data
//        case 401:
//            throw RequestError.unauthorized
//        default:
//            throw RequestError.unexpectedStatusCode
//        }
//    }
// 
//    func get() async throws -> T {
//        let data = try await getData()
//        return try JSONDecoder().decode(T.self, from: data)
//    }
//}
//
//struct Movie: Decodable {}
//extension MoviesEndpoint: EndpointBis {
//    typealias T = [Movie]
//}
//
//struct Category: Decodable {}
//
//struct CategoriesEndpoint: EndpointBis {
//    typealias T = Category
//}
//
//enum Api {
//    static let categories = CategoriesEndpoint()
//    static func movies(_ endpoint: MoviesEndpoint) -> MoviesEndpoint { endpoint }
//}
//
//enum MoviesApi {
//    case categories
//    case topRated
//    case popular
//    case upcoming
//    case movie(id: Int)
//    case movies(MoviesEndpoint)
//    
//    var endpoint: any EndpointBis {
//        switch self {
//        case .categories: return CategoriesEndpoint()
//        case .movie(let id): return  MoviesEndpoint.standalone(id: id)
//        case .topRated: return MoviesEndpoint.topRated
//        case .popular: return MoviesEndpoint.popular
//        case .upcoming: return MoviesEndpoint.upcoming
//        case .movies(let endpoint): return endpoint
//        }
//    }
//    
//    func get<T: Decodable>() async throws -> T {
//        let data = try await endpoint.getData()
//        return try JSONDecoder().decode(T.self, from: data)
//    }
//}
//
//fileprivate func main2() async throws {
//    let _ = try await MoviesEndpoint.popular.get()
//    let _ = try await MoviesEndpoint.topRated.get()
//    let _ = try await MoviesEndpoint.standalone(id: 25).get()
//    let _ = try await Api.categories.get()
//    let _ = try await Api.movies(.popular).get()
//    let _: [Category] = try await MoviesApi.categories.get()
//    let _: Movie = try await MoviesApi.movies(.standalone(id: 1)).get()
//}
