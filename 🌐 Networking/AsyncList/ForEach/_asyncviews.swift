//
//  _asyncviews.swift
//  ForEach
//
//  Created by Cristian Felipe Patiño Rojas on 01/04/2024.
//

import SwiftUI

protocol AsyncList: View {
    associatedtype Row: View
    var url: String { get set }
    func row(_ item: MJ) -> Row
}

extension AsyncList {
    var body: some View {
        AsyncForEach(url, row)
    }
}

struct AsyncForEach<T: View>: View {
    let url: String
    let row: (MJ) -> T

    init(_ url: String, _ row: @escaping (MJ) -> T) {
        self.url = url
        self.row = row
    }

    var body: some View {
        DataGetter(url) { state in
            LazyVStack {
                ForEach(state.arrayValue, id: \.description) {
                    row($0)
                }
            }
        }
    }
}

struct DataGetter<T: View>: View, NetworkGetter {
    let url: String
    let closure: (MJ) -> T
    @State var state = ViewState.loading
    
    init(_ url: String, closure: @escaping (MJ) -> T) {
        self.url = url
        self.closure = closure
    }
    
    var body: some View {
        switch state {
        case .loading: ProgressView().onAppear(perform: fetchData)
        case .success(let data): closure(data)
        case .error(let error): Text(error)
        case .empty: "No data found"
        }
    }
    
    private func fetchData() {
        fetchData(url: url) { result in
            switch result {
            case .success(let data): state = .success(MJ(data: data))
            case .failure(let error): state = .error(error.localizedDescription)
            }
        }
    }
}


extension String: View {
    public var body: Text { Text(self) }
}
