//
//  ReduxProtocolApp.swift
//  ReduxProtocol
//
//  Created by Cristian Felipe Patiño Rojas on 19/12/2023.
//

import SwiftUI

@main
struct ReduxProtocolApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                
                Example_1().tabItem {
                    Text(Example_1.title)
                }
                
                Example_2().tabItem {
                    Text(Example_2.title)
                }
                
                Example_3().tabItem {
                    Text(Example_3.title)
                }
            }
        }
    }
}
