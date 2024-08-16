//
//  _tmdb.swift
//  SwiftUIRenderer
//
//  Created by Cristian Felipe Patiño Rojas on 18/04/2024.
//

import Foundation

enum TMDb {
    
    static let apiKey = "b5f1e193c3a2759a19f3f085f3dc2d7e"

    static var baseComponents: URLComponents {
        var components = URLComponents(string: "https://api.themoviedb.org/3")
        let items = URLQueryItem(name: "api_key", value: apiKey)
        components?.queryItems = [items]
        return components!
    }

    static var baseURL: URL { baseComponents.url! }
    
    // Resources
    static let popular = baseURL.appendingPathComponent("movie/popular")
    static let now_playing = baseURL.appendingPathComponent("movie/now_playing")
    static let genres = baseURL.appendingPathComponent("genre/movie/list")
   
    static func movie(id: Int) -> URL {
        baseURL.appendingPathComponent("/movie/\(id)")
    }
    
    static func videos(id: Int) -> URL {
        baseURL.appendingPathComponent("/movie/\(id)/videos")
    }
    
    static func credits(id: Int) -> URL {
        baseURL.appendingPathComponent("/movie/\(id)/credits")
    }
    
    static func genre(id: Int) -> URL {
        var components = baseComponents
        components.queryItems?.append(.init(name: "with_genres", value: id.description))
        return components.url!.appendingPathComponent("discover/movie")
    }
}
