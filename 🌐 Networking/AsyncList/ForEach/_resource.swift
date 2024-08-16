//
//  _resource.swift
//  ForEach
//
//  Created by Cristian Felipe Patiño Rojas on 01/04/2024.

import Foundation

final class ProductResource: ObservableObject, NetworkGetter {
    @Published var state = ViewState.loading
    
    func loadData(id: Int) {
        fetchData(url: makeURL(id), completion: handle)
    }
    
    private func makeURL(_ id: Int) -> String {
        "http://localhost:3000/products?sellerId=\(id)"
    }
    
    func handle(_ result: Result<Data, Error>) {
        DispatchQueue.main.async { [weak self] in
            switch result {
            case .success(let data) : self?.updateState(.success(MJ(data: data)))
            case .failure(let error): self?.updateState(.error(error.localizedDescription))
            }
        }
    }
    
    func updateState(_ state: ViewState) {
        DispatchQueue.main.async {
            self.state = state
        }
    }
    
    func create(productName: String, sellerId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let baseURL = URL(string: "http://localhost:3000/products")!
        let newProduct = MJ(["title": productName, "sellerId": sellerId])
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"

        do {
            let jsonData = try newProduct.encode()
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
            print("Error encoding product: \(error.localizedDescription)")
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            if let error = error {
                self.updateState(.error(error.localizedDescription))
                completion(.success(()))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                self.updateState(.error("Respuesta invalida del servidor"))
                completion(.failure(NSError(domain: "invalido", code: 0)))
                return
            }
            
            if (200..<300).contains(httpResponse.statusCode) {
                self.updateState(self.state.appending(data: MJ(data: data!)))
                completion(.success(()))
            } else {
                self.updateState(.error("Error: \(httpResponse.statusCode)"))
                completion(.failure(NSError(domain: "invalido", code: 0)))
            }
        }

        task.resume()
    }
}
