//
//  ApiClient.swift
//  Networking
//
//  Created by Cristian Felipe Patiño Rojas on 02/12/2023.
//

import Foundation
import Networking
import Combine
//
typealias AppRequest<T: Codable> = Request<Wrapper<T>>

public final class API: Service {
    public static var mods = [String : (inout URLRequest) -> Void]()
    public var baseURL = "https://backend.test/api/"
    let counters = Counters()
    static let shared = API()
    private init() {}
}

/// @comment: This way of injecting only works if we have a single api service
extension Resource {
    static var service: Service { API.shared }
}

extension API {
    final class Counters: Resource {
        static var mods = [String : (AppRequest<[Count]>) -> AppRequest<[Count]>]()
        var cancellable: AnyCancellable?
        var url: String = "counters"
        var error: Error?
        var response: HTTPURLResponse?
        var contentType = "application/json"
        
        @Published var data: Wrapper<[Count]> = Wrapper(data: [])
        var counts: [Count] {data.data}
    }
}
