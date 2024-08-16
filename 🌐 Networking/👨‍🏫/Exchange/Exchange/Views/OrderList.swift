//
//  OrderList.swift
//  Exchange
//
//  Created by JimLai on 2020/2/28.
//  Copyright © 2020 stargate. All rights reserved.
//

import SwiftUI

struct OrderList: View {
    @EnvironmentObject var shared: SharedState
    @EnvironmentObject var ws: WS

    var orderList: some View {
            ScrollView(showsIndicators: true) {
                ForEach(ws.orderRows) { order in
                    HStack(alignment: .center, spacing: 5) {
                        HStack {
                            Text(order.b.quantity).foregroundColor(.rowWhite).padding(10)
                            Spacer()
                            Text(order.b.price).foregroundColor(.bidGreen).padding(10)
                        }
                        HStack {
                            Text(order.a.price).foregroundColor(.askRed).padding(10)
                            Spacer()
                            Text(order.a.quantity).foregroundColor(.rowWhite).frame(alignment: .trailing).padding(10)
                        }
                    }.background(self.rowBG(CGFloat(order.bqRatio), CGFloat(order.aqRatio)))
                }.frame(maxWidth: .infinity)
            }.background(Color.black)
    }
    func rowBG(_ lratio: CGFloat, _ rratio: CGFloat) -> some View {
        GeometryReader { geo in
            ZStack {
                HStack(spacing: 0) {
                    Rectangle().fill(Color.black).frame(width: geo.size.width * (1-lratio) * 0.5)
                    Rectangle().fill(Color.ratioDarkGreen).frame(width: geo.size.width * lratio * 0.5)
                    Rectangle().fill(Color.ratioDarkRed).frame(width: geo.size.width * rratio * 0.5)
                    Rectangle().fill(Color.black).frame(width: geo.size.width * (1-rratio) * 0.5)
                }
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Header()
            if shared.isPopover {
                orderList.overlay(Popover().offset(x: 5, y: -20).padding(), alignment: .topTrailing)
            } else {
                orderList
            }

        }.background(Color.black)
    }
}

struct OrderList_Previews: PreviewProvider {
    static var previews: some View {
        OrderList()
    }
}
