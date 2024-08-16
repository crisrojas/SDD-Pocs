//
//  CountersApp.swift
//  Counters
//
//  Created by Cristian Felipe Patiño Rojas on 01/12/2023.
//

import SwiftUI
import Networking

fileprivate let backend = Backend(id: "prod")

@main
struct CountersApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().onAppear(perform: backend.startInterceptingRequests)
        }
    }
}

