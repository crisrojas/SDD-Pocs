//
//  File.swift
//  
//
//  Created by Cristian Felipe Patiño Rojas on 09/05/2023.
//

import SwiftUI

struct PieProgress: View {
  
  @State var isHovering = false
  let progress: Double
    private let color = Color.systemGray
  var body: some View {
    Circle()
          .stroke(color, lineWidth: 1.5)
      .overlay(
        PieShape(progress: progress)
            .padding(.sizing(0.5))
            .foregroundColor(color)
      )
//      .frame(maxWidth: .infinity)
      .aspectRatio(contentMode: .fit)
      .onHover { isHovering = $0 }
  }
}
