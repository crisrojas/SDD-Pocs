//
//  Popover.swift
//  Exchange
//
//  Created by JimLai on 2020/2/29.
//  Copyright © 2020 stargate. All rights reserved.
//

import SwiftUI

struct Popover: View {
    @EnvironmentObject var ws: WS
    @EnvironmentObject var shared: SharedState
    var popWidth: CGFloat {
        80
    }
    var popHeight: CGFloat {
        160
    }
    var popTriangle: some View {
        Path { path in
            path.move(to: CGPoint(x: 5, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 10))
            path.addLine(to: CGPoint(x: 10, y: 10))
        }.fill(Color.pickerGray).frame(width: 10, height: 10)
    }
    func onSelected(_ index: Int) {
        ws.onDecimalPlaceChange(index)
        shared.isPopover.toggle()
    }
    var body: some View {
        VStack(spacing: 10) {
            ForEach(1 ..< 5) { index in
                if self.ws.decimalPlaces ?? 0 == index {
                    Button(String(index)) {
                        self.onSelected(index)
                    }.foregroundColor(.yellow)
                } else {
                    Button(String(index)) {
                        self.onSelected(index)
                    }.foregroundColor(.gray)
                }
            }
        }.frame(width: popWidth, height: popHeight).background(RoundedRectangle(cornerRadius: 10).fill(Color.pickerGray))
        .overlay(popTriangle.offset(x: 0, y: -popHeight/2-5))
    }
}

struct Popover_Previews: PreviewProvider {
    static var previews: some View {
        Popover()
    }
}
