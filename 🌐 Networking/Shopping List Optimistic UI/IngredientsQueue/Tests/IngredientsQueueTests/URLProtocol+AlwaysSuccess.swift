//
//  File 2.swift
//  
//
//  Created by Cristian Felipe Patiño Rojas on 16/08/2024.
//

import Foundation

extension URLProtocol {
    class AlwaysSuccess: URLProtocol {
        static var testURLs = [URL?: Data]()
        static var requests = [URLRequest]()
        override class func canInit(with request: URLRequest) -> Bool {
            true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }
        
        override func startLoading() {
            Self.requests.append(request)
            if let url = request.url, let data = Self.testURLs[url] {
                self.client?.urlProtocol(self, didLoad: data)
            }
            
            // Simulate a success response
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            self.client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(Self.self)
            Self.requests.removeAll()
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(Self.self)
        }
    }
}
