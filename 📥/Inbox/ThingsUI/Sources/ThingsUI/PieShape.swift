//
//  File.swift
//  
//
//  Created by Cristian Felipe Patiño Rojas on 09/05/2023.
//

import SwiftUI

struct PieShape: Shape {
  var progress: Double = 0.0
  private let startAngle: Double = (Double.pi) * 1.5
  private var endAngle: Double {
    get {
      return self.startAngle + Double.pi * 2 * self.progress
    }
  }
  
  func path(in rect: CGRect) -> Path {
    var path = Path()
    let arcCenter =  CGPoint(x: rect.size.width / 2, y: rect.size.width / 2)
    let radius = rect.size.width / 2
    path.move(to: arcCenter)
    path.addArc(center: arcCenter, radius: radius, startAngle: Angle(radians: startAngle), endAngle: Angle(radians: endAngle), clockwise: false)
    path.closeSubpath()
    return path
  }
}
