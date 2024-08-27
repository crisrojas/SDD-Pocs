//
//  ContentView.swift
//  ThingsKit
//
//  Created by Cristian Felipe Patiño Rojas on 15/03/2023.
//

import SwiftUI

// ThingsSwiftUI

struct Project {}

struct ProjectRow: View {
    let editing: Bool
    var body: some View {
        HStack(spacing: .sizing(2)) {
            PieProgress(progress: 0.6)
                .frame(width: .sizing(5))
               
            Text("Title")
                .fontWeight(.semibold)
            Spacer()
            if editing {
                Image(systemName: "circle")
            }
        }
        .contentShape(Rectangle())
        .font(.headline)
        .padding(.vertical, .sizing(3))
        .padding(.horizontal, .sizing(2))
        .cornerRadius(.sizing())
    }
}

