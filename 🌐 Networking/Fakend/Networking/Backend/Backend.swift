//
//  Backend.swift
//  Networking
//
//  Created by Cristian Felipe Patiño Rojas on 01/12/2023.
//

import Foundation

public final class Backend {
   
    public lazy var counters = BackendResource<Count>(
        parentId: id,
        baseURL: Backend.baseURL,
        path: "counters"
    )
    
    static let baseURL = "https://backend.test/api/"
    let id: String
    
    public init(id: String) {self.id = id}

    public func destroy() throws {
        try counters.destroyDb()
    }
}


extension Backend {
    func handle(_ request: URLRequest) -> (Data, URLResponse) {
        guard let components = request.url?.pathComponents else {
            return ErrorDataResponse(url: "https://backend.test/api", statusCode: 400)
        }
        
        if components.penultimate == counters.path || components.last == counters.path {
            return counters.handle(request)
        }
        
        return ErrorDataResponse(url: request.url!.absoluteString, statusCode: 404)
    }
}

