import Foundation

protocol ItemNetworker {}

extension ItemNetworker {
    var baseURL: URL { URL(string: "http://localhost:3000/items")! }
    var urlSession: URLSession { URLSession.shared }
    
    func fetch() async throws -> [Item] {
        var request = URLRequest(url: baseURL)
        request.httpMethod = "GET"
        let (data, response) = try await urlSession.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let items = try JSONDecoder().decode([Item].self, from: data)
        return items
    }

    func toggle(_ item: Item) async throws {
        
        print("🔄 Toggling \(item.name)...")
        
        // Simulate network delay
        try await Task.sleep(for: .seconds(2))
        
        let url = baseURL.appendingPathComponent(item.id.description)
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var updatedItem = item
        updatedItem.isChecked.toggle()
        let data = try JSONEncoder().encode(updatedItem)
        request.httpBody = data
        
        let (_, response) = try await urlSession.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        print("✅ \(item.name) toggled")
    }
}
