//
//  BonfireApp.swift
//  Bonfire
//
//  Created by Cristian Felipe Patiño Rojas on 02/12/2023.
//

import SwiftUI

struct BonfireApp: App {
    @ObservedObject var resource = api.employeesCodable
    var body: some Scene {
        WindowGroup {
            resource
                .employes
                .onAppear(perform: {resource.load()})
                .navigationfy()
        }
    }
}

// Usage of 2nd implementation
@main
struct BonfireApp2: App {
    @ObservedObject var resource = API_Bis.shared.employees
    var body: some Scene {
        WindowGroup {
            NavigationView {
                VStack {
                    switch resource.state {
                    case .loading(let cachedData):
                        if let cachedData {
                            cachedData
                        } else {
                            loadView
                        }
                    case .success(let employees):
                        employees
                    case .error(let error): error
                    }
                }
                .toolbar {
                   
                    // Don't show on first load (data == nil)
                    if resource.state.data != nil {
                       reloadButton
                    }
                }
            }
        }
    }

    // Updates without showing activity indicator if cachedData
    var reloadButton: some View {
        Button {
            resource
                .load()
                .onCompletion {
                    print("Complete") // works sometimes ?
                }
        } label: {
            if resource.state.isLoading {
                ProgressView()
            } else {
                Image(systemName: "arrow.counterclockwise")
            }
        }
        .disabled(resource.state.isLoading)
    }
    
    var loadView: some View {
        ProgressView().onAppear {
            resource.load()
        }
    }
}
