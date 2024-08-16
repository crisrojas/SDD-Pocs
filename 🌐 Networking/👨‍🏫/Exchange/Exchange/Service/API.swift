
import SwiftUI
import Combine

typealias P = Params
typealias PD = [P: Any]

enum Params: String {
    case none, e, E, s, U, u, b, a, p, q, f, l, T, m, M
    case asks, bids, lastUpdateId
}

enum NetError: String, Error {
    case httpError, errorResponse, decodeError, preError
}

typealias Request<T> = AnyPublisher<T, Error>

protocol ResDecodable {
    static func decode(_ data: Data) -> Self?
}

/// Un recurso tiene:
/// Una url a partir de la cual se construye una URLRequest
/// Un método get() para recuperar el recurso.
/// Un método post() para mandar el recurso.
/// Unos métodos onSuccess y onFailure para gestionar la respuesta
/// Un método request para devoler un publisher a partir de una request.
/// Un método sink para gestionar la respuesta?
protocol Resource: AnyObject {
    associatedtype DataType: ResDecodable
    var url: String { get set }
    var baseReq: URLRequest? {get}
    
    var success: ((DataType) -> ())? { get set }
    var failure: ((Error) -> ())? { get set }
    func onSuccess(_ cb: @escaping (DataType) -> ()) -> Self
    func onFailure(_ cb: @escaping (Error) -> ()) -> Self
    
    func post(_ pd: [Params: String]) -> AnyCancellable?
    func get() -> AnyCancellable?
    
    func request(_ req: URLRequest) -> Request<DataType>
    func preError()
    func sink(_ request: Request<DataType>) -> AnyCancellable
}

extension Resource {
    /// Almacena el closure que será ejecutado en caso de éxito
    @discardableResult
    func onSuccess(_ cb: @escaping (DataType) -> ()) -> Self {
        success = cb
        return self
    }

    /// Almacena el closure que será ejecutado en caso de error
    @discardableResult
    func onFailure(_ cb: @escaping (Error) -> ()) -> Self {
        failure = cb
        return self
    }
    
    /// Construimos una respuesta por defecto
    var baseReq: URLRequest? {
        guard let url = URL(string: url) else {return nil}
        return URLRequest(url: url)
    }
    
    /// Creamos un publisher a partir de una request
    func request(_ req: URLRequest) -> Request<DataType> {
        URLSession.shared.dataTaskPublisher(for: req).tryMap { result in
            guard let resp = result.response as? HTTPURLResponse, 200 ..< 300 ~= resp.statusCode else {
                throw NetError.errorResponse
            }
            guard let d = DataType.decode(result.data) else {
                throw NetError.decodeError
            }
            return d
        }.eraseToAnyPublisher()
    }

    func preError() {
        DispatchQueue.main.async { [weak self] in
            self?.failure?(NetError.preError)
        }
    }
    
    /// Gestionamos la request y ejecutamos los closures de error/éxito
    func sink(_ request: Request<DataType>) -> AnyCancellable {
        request.receive(on: RunLoop.main).sink(receiveCompletion: { [weak self] (completion) in
            switch completion {
            case .finished:
                break
            case .failure(let e):
                self?.failure?(e)
            }
        }) { [weak self] data in
            self?.success?(data)
        }
    }
}

/// Tenemos un objeto Json que conforma a recurso.
/// Es decir, es un recurso genérico.
/// Cuyo datatype es otro objeto JSON capitalizado
/// Es decir, se llama igual, pero es diferente.
/// Y será lo que el recurso devuelva al utilizar la api del protocolo Resource
final class Json: Resource {
    
    var url: String
    
    var success: ((JSON) -> ())?
    var failure: ((Error) -> ())?

    init(_ url: String) {
        self.url = url
    }
    
    func get() -> AnyCancellable? {
        guard var req = baseReq else {
            preError()
            return nil
        }
        req.httpMethod = "GET"
        return sink(request(req))
    }

    func post(_ urlParams: [Params: String]) -> AnyCancellable? {
        guard var req = baseReq else {
            preError()
            return nil
        }
        req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        req.httpMethod = "POST"
        return sink(request(req))
    }
}

/// Se usa de esta manera:
func jsonUsage() {
    let jsonTest = Json("https://myurl.com/collection")
    _ = jsonTest
        .onSuccess { json in
            // hanlde(json)
        }
        .get()
}

/// Podría usarse con un tipo custom en vez del JSON de esta manera:
///
final class JsonBis<T: ResDecodable>: Resource {
    
    var url: String
    
    var success: ((T) -> ())?
    var failure: ((Error) -> ())?

    init(_ url: String) {
        self.url = url
    }
    
    func get() -> AnyCancellable? {
        guard var req = baseReq else {
            preError()
            return nil
        }
        req.httpMethod = "GET"
        return sink(request(req))
    }

    func post(_ urlParams: [Params: String]) -> AnyCancellable? {
        guard var req = baseReq else {
            preError()
            return nil
        }
        req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        req.httpMethod = "POST"
        return sink(request(req))
    }
}

struct MyCustomType: Decodable, ResDecodable {
    static func decode(_ data: Data) -> MyCustomType? {
        try? JSONDecoder().decode(Self.self, from: data)
    }
}

let customResource = JsonBis<MyCustomType>("urltoretrieve.com/path")

/// Transrorma un diccionario en un dicionnario de string:any de forma recursiva
public extension Dictionary where Key: RawRepresentable, Key.RawValue == String {
    func toStringKey() -> [String: Any] {
        var d = [String: Any]()
        for k in self.keys {
            let v = self[k]!
            if let x = v as? [Key: Any] {
                d[k.rawValue] = x.toStringKey()
            }
            else {
                d[k.rawValue] = v
            }
        }
        return d
    }
}


