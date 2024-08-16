//
//  _otherviews.swift
//  ForEach
//
//  Created by Cristian Felipe Patiño Rojas on 02/04/2024.
//

import SwiftUI

struct AddProduct: View {
    @EnvironmentObject var products: ProductResource
    @Environment(\.dismiss) var dismiss
    @State var productName: String = ""
    @State var state: ViewState = .idle
    let sellerId: Int
    
    enum ViewState: Equatable {
        case idle
        case loading
        case success
        case error(String)
    }
    
    var body: some View {
        VStack {
            TextField("name", text: $productName)
            switch state {
            case .idle, .success: EmptyView()
            case .loading: ProgressView()
            case .error(let error): Text(error)
            }
            
            Button("Add") {
                products.create(productName: productName, sellerId: sellerId) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success: dismiss()
                        case .failure(let error): state = .error(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
}

struct ProductList: View, NetworkGetter {
    @StateObject var products = ProductResource()
    let id: Int
    var body: some View {
        switch products.state {
        case .loading: ProgressView().onAppear(perform: loadData)
        case .success(let data): productList(data)
        case .error(let error): Text(error)
        case .empty: "No data found yet"
        }
    }
    
    @ViewBuilder
    func productList(_ data: MJ) -> some View {
        if data.arrayValue.isEmpty {
            Text("No products")
        } else {
            VStack {
                NavigationLink("Add product") {
                    AddProduct(sellerId: id).environmentObject(products)
                }
                ForEach(data.arrayValue, id: \.id) { product in
                    product.title.stringValue
                }
            }
        }
    }
    
    func loadData() {
        products.loadData(id: id)
    }
}



