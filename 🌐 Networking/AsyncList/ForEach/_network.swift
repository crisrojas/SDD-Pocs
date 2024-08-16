//
//  _network.swift
//  ForEach
//
//  Created by Cristian Felipe Patiño Rojas on 01/04/2024.
//

import Foundation


protocol NetworkGetter {}

extension NetworkGetter {
    func fetchData(url: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: url) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                completion(.failure(error!))
                return
            }
            
            completion(.success(data))
        }.resume()
    }
}
