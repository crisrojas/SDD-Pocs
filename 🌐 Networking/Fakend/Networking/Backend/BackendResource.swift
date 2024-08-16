//
//  BackendResource.swift
//  Networking
//
//  Created by Cristian Felipe Patiño Rojas on 01/12/2023.
//

import Foundation

public protocol PostEncodable {
    associatedtype POST: Decodable
    init(post: POST)
}

public protocol PutEncodable {
    associatedtype PUT: Decodable
    func from(put: PUT) -> Self
}

public protocol PatchEncodable {
    associatedtype PATCH: Decodable
    func from(patch: PATCH) -> Self
}

public typealias ResourceType = Identifiable & Codable & PostEncodable & PutEncodable & PatchEncodable

public final class BackendResource<T: ResourceType>: FileCoder {
   
    lazy var db: [String:T] = readDb() {didSet{persist()}}
    let parentId: String
    let baseURL: String
    let path: String
    
    var dbData: Data {
        Wrapper(data: db.map {$0.value}).encoded()
    }
    
    public var dbPath: String {
        "db" + "-" + parentId + "-" + path + ".json"
    }
    
    public init(parentId: String, baseURL: String, path: String) {
        self.parentId = parentId
        self.baseURL = baseURL
        self.path = path
    }
    
    public func readDb() -> [String:T] {
        read(dbPath) ?? [:]
    }
    
    func persist() {
        try? write(db, to: dbPath)
    }
    
    public func destroyDb() throws {
        do {
            try destroy(dbPath)
        } catch {
            /// Error == 4 means we can destroy because the file doesn't exist.
            /// We want to ignore that case when trying to destroy the db, specially during test teardown
            guard (error as NSError).code != 4 else {
                return
            }
            throw error
        }
        
    }
    
    public func upsert(_ item: T) {
        db[String(describing:item.id)] = item
    }
    
    public func delete(_ item: T) {
        db[String(describing:item.id)] = nil
    }
    
    public func handle(_ request: URLRequest) -> (Data, URLResponse) {
        
        let url = request.url!
        let urlStr = url.absoluteString
        let components = url.pathComponents
        
        /// Response can be send with different case making the switch cases evalute to false
        switch request.httpMethod?.uppercased() {
        case "GET":
            if components.penultimate == path {
                let id = components.last!
                let item = db[id]
                let wrapped = Wrapper(data: item)
                let encoded = wrapped.encoded()
                return SuccessDataResponse(encoded, url: urlStr)
            }
            
            if components.last == path {
                return SuccessDataResponse(dbData, url: urlStr)
            }
        case "POST":
            if components.last == path,
               let data = dataFromBody(request),
               let cmd = try? jsonDecoder.decode(T.POST.self, from: data) {
                let newItem = T(post: cmd)
                db[String(describing: newItem.id)] = newItem
                return SuccessDataResponse(url: urlStr)
            }
        case "PUT":
            if components.penultimate == path,
                let data = request.httpBody,
                let cmd = try? jsonDecoder.decode(T.PUT.self, from: data),
                let item = db[components.last!]
            {
                db[components.last!] = item.from(put: cmd)
                return SuccessDataResponse(url: urlStr)
            }
        case "PATCH":
            if components.penultimate == path,
                let data = dataFromBody(request),
                let cmd = try? jsonDecoder.decode(T.PATCH.self, from: data),
                let item = db[components.last!]
            {
                db[components.last!] = item.from(patch: cmd)
                return SuccessDataResponse(url: urlStr)
            }
        case "DELETE":
            if components.penultimate == path {
                db[components.last!] = nil
                return SuccessDataResponse(url: urlStr)
            }
            
            if components.last == path {
                db = [:]
                return SuccessDataResponse(url: urlStr)
            }
        default: break
        }
       
        return ErrorDataResponse(url: urlStr)
    }
    
    /// URLSession wipes httpBody on a POST request and creates a stream instead.
    /// So we need a method that creates Data that from stream or body independently if
    /// the handle of the post if made from a request passed through URLProtocol or a request passed directly.
    func dataFromBody(_ request: URLRequest) -> Data? {
        guard let stream = request.httpBodyStream else { return request.httpBody }
        return try? Data(reading: stream)
    }
}


extension Array {
    var penultimate: Element? {
        guard count > 2 else {
           return nil
        }
        return self[count-2]
    }
}


// MARK: - Responses
/// Maybe good to restrict statusCodes to a range
func SuccessDataResponse(_ data: Data? = nil, url: String, statusCode: Int = 200) -> (Data, URLResponse) {
     let response = HTTPURLResponse(
            url: URL(string: url)!,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )!
    
    return (data ?? Data(), response)
}

func ErrorDataResponse(url: String, statusCode: Int = 400) -> (Data, URLResponse) {
    struct ErrorData: Encodable {
        let error: Bool
        let message: String
    }

    let data = ErrorData(error: true, message: "No data found").encoded()
    let response = HTTPURLResponse(
        url: URL(string: url)!,
        statusCode: statusCode,
        httpVersion: "HTTP/1.1",
        headerFields: nil)!
    return (data, response)
}

