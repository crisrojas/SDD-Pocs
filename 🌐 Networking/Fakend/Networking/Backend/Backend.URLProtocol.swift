//
//  Backend.URLProtocol.swift
//  Networking
//
//  Created by Cristian Felipe Patiño Rojas on 01/12/2023.
//

import Foundation

extension Backend {
    final class URLProtocolStub: URLProtocol {
        static var dataGetter: ((URLRequest) -> (Data, URLResponse))?
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }
        
        override func startLoading() {
            guard let data = Self.dataGetter?(request) else {
                let error = NSError(domain: "No data found for requested url: \(request.url?.absoluteString ?? "No url found")", code: 0)
                client?.urlProtocol(self, didFailWithError: error)
                return
            }
            
            client?.urlProtocol(self, didReceive: data.1, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data.0)
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}

extension Backend {
    var urlProtocol: URLProtocolStub { .init() }
    
    public func startInterceptingRequests() {
        URLProtocolStub.dataGetter = handle(_:)
        URLProtocolStub.startInterceptingRequests()
    }
    public func stopInterceptingRequests()  {
        URLProtocolStub.stopInterceptingRequests()
    }
}
