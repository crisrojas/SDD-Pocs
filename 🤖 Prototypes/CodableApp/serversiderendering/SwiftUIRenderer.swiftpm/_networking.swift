import SwiftUI

func dp(_ any: Any) {
    #if DEBUG
    print(any)
    #endif
}

typealias Result<T> = Swift.Result<T, Error>
typealias Completion<T> = (Result<T>) -> Void

protocol NetworkGetter {}
extension NetworkGetter {
    func dispatch<T>(_ queue: DispatchQueue?, completion: @escaping Completion<T>) -> Completion<T> {{ result in
        if let queue {
            queue.async { completion(result) }
        } else {
            completion(result)
        }
    }}
    
    func fetchData(url: URL, dispatchOn queue: DispatchQueue? = nil, completion: @escaping Completion<JSON>) {
        let dispatch = dispatch(queue, completion: completion)
        fetchData(url: url) { (result: Result<Data>) in
            switch result {
            case .success(let data):
                // Not sure if dispatching decoding in a different queue
                // really helps...
                DispatchQueue.global(qos: .background).async {
                    do {
                        let json = try JSON(data: data)
                        dispatch(.success(json))
                    } catch {
                        dispatch(.failure(error))
                    }
                }
            case .failure(let error): dispatch(.failure(error))
            }
        }
    }
    
    func fetchData(url: URL, dispatchOn queue: DispatchQueue? = nil, completion: @escaping Completion<Data>) {
        
        let dispatch = dispatch(queue, completion: completion)
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                dispatch(.failure(error!))
                return
            }
            
            dispatch(.success(data))
            dp(url.absoluteString + ":")
        }.resume()
    }
    
    func fetchData(url: URL) async throws -> (Data, URLResponse) {
        try await URLSession.shared.data(from: url)
    }
}

import SwiftUI

enum ResourceState: Equatable {
    case loading
    case success(JSON)
    case error(String)
}

extension ResourceState {
    var isSuccess: Bool {
        switch self {
        case .success: return true
        default: return false
        }
    }
    
    var data: JSON? {
        switch self {
        case .success(let data): return data
        default: return nil
        }
    }
    
    mutating func appendData(_ newData: JSON) {
        guard let data else { return }
        let current = data.array
        let new = newData.array
        let final = current + new
        self = .success(.array(final))
    }
}


extension ResourceState {
    init(from result: Result<JSON>) {
        switch result {
        case .success(let data): self = .success(data)
        case .failure(let error): self = .error(error.localizedDescription)
        }
    }
}

struct AsyncJSON<C: View, P: View, E: View>: View, NetworkGetter {

    @State var state = ResourceState.loading
    
    let url: URL
    
    @ViewBuilder var content: (JSON) -> C
    @ViewBuilder var placeholder: () -> P
    @ViewBuilder var error: (String) -> E
   
    init(
        url: URL,
        @ViewBuilder content: @escaping (JSON) -> C,
        @ViewBuilder placeholder: @escaping () -> P = {ProgressView()},
        @ViewBuilder error: @escaping (String) -> E = {Text($0)}
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
        self.error = error
    }
    
    init(
        url: String,
        @ViewBuilder content: @escaping (JSON) -> C,
        @ViewBuilder placeholder: @escaping () -> P = {ProgressView()},
        @ViewBuilder error: @escaping (String) -> E = {Text($0)}
    ) {
        self.url = URL(string: url)!
        self.content = content
        self.placeholder = placeholder
        self.error = error
    }
    
    
    var body: some View {
        switch state {
        case .loading: loading()
        case .success(let data): content(data)
        case .error(let error): self.error(error)
        }
    }
    
    func loading() -> some View {
        placeholder().onAppear {
            fetchData(url: url, dispatchOn: .main) { result in
                switch result {
                case .success(let data):
                    state = .success(data)
                case .failure(let error):
                    state = .error(error.localizedDescription)
                }
            }
        }
    }
}
