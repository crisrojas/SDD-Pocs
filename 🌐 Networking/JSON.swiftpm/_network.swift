//
//  _network.swift
//  Movies
//
//  Created by Cristian Felipe Patiño Rojas on 10/04/2024.
//

import Foundation

func dp(_ msg: Any) {
    #if DEBUG
        print(msg)
    #endif
}

enum TmdbApi {
    
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


typealias Completion<T> = (Result<T, Error>) -> Void

protocol NetworkGetter {}
extension NetworkGetter {
    func fetchData(url: String, completion: @escaping Completion<Data>) {
        guard let url = URL(string: url) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                completion(.failure(error!))
                return
            }
            
            completion(.success(data))
            dp(url.absoluteString + ":")
            
        }.resume()
    }
}

import SwiftUI

enum ResourceState {
    case loading
    case success(MJ)
    case error(String)
}

extension ResourceState {
    var isSuccess: Bool {
        switch self {
        case .success: return true
        default: return false
        }
    }
    
    var data: MJ? {
        switch self {
        case .success(let data): return data
        default: return nil
        }
    }
    
    mutating func appendData(_ newData: MJ, keyPath: String) {
        guard let data else { return }
        let finalData = data[keyPath].array + newData[keyPath].array
        let anyArray: [Any] = finalData.map { $0.jsonObject }
        let jsonObject: [String: Any] = [keyPath: anyArray]
        let magicJSON = MagicJSON.dict(jsonObject)
        self = .success(magicJSON)
    }
}

extension ResourceState {
    init(from result: Result<MJ, Error>) {
        switch result {
        case .success(let data): self = .success(data)
        case .failure(let error): self = .error(error.localizedDescription)
        }
    }
}

struct AsyncJSON<T: View>: View, NetworkGetter {
    
    @State var state = ResourceState.loading
    
    let url: URL
    let keyPath: String?
    @ViewBuilder var closure: (MJ) -> T
    
    init(_ url: URL, keyPath: String? = "results", @ViewBuilder closure: @escaping (MJ) -> T) {
        self.url = url
        self.keyPath = keyPath
        self.closure = closure
    }
    
    func result(_ mj: MJ) -> MJ {
        keyPath == nil ? mj : mj[keyPath!]
    }

    var body: some View {
        switch state {
        case .loading: ProgressView().onAppear(perform: fetchData)
        case .success(let data): closure(result(data))
        case .error(let error): Text(error)
        }
    }
    
    private func fetchData() {
        fetchData(url: url.absoluteString) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data): state = .success(MJ(data: data))
                case .failure(let error): state = .error(error.localizedDescription)
                }
            }
        }
    }
}
