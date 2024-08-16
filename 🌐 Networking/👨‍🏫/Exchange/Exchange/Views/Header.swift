//
//  Header.swift
//  Exchange
//
//  Created by JimLai on 2020/2/28.
//  Copyright © 2020 stargate. All rights reserved.
//

import SwiftUI

struct Header: View {
    @EnvironmentObject var shared: SharedState
    @EnvironmentObject var ws: WS
    var triangle: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 10, y: 0))
            path.addLine(to: CGPoint(x: 5, y: 10))
            }.fill(Color.yellow).frame(width: 10, height: 10)
    }
    var body: some View {
        HStack(spacing: 0) {
            HStack {
                Text("Bid").foregroundColor(.headerGray).padding()
                Spacer()
            }
            HStack {
                Text("Ask").foregroundColor(.headerGray).padding()
                Spacer()
                VStack(alignment: .trailing) {
                    HStack(spacing: 5) {
                        if ws.decimalPlaces != nil {
                            Button(NSDecimalNumber(decimal: 1 / ws.multiplier).stringValue) {
                                self.shared.isPopover.toggle()
                            }.foregroundColor(.rowWhite)
                            triangle
                        }
                    }.background(Color.pickerGray).padding()
                }
            }
        }
    }
}

struct Header_Previews: PreviewProvider {
    static var previews: some View {
        Header()
    }
}
