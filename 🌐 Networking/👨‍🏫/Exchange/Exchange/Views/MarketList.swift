//
//  MarketList.swift
//  Exchange
//
//  Created by JimLai on 2020/2/28.
//  Copyright © 2020 stargate. All rights reserved.
//

import SwiftUI

struct MarketItem: Identifiable {
    var id: Int {
        j[P.a].intValue
    }
    let j: JSON

    init(_ json: JSON, _ pc: Color) {
        j = json
        priceColor = pc
    }

    var time: String {
        MarketItem.df.string(from: Date(timeIntervalSince1970: j[P.T].doubleValue / 1000))
    }
    var price: String {
        round(j[P.p].stringValue, 3)
    }

    let priceColor: Color

    var quantity: String {
        round(j[P.q].stringValue, 2)
    }

    func round(_ des: String, _ scale: Int) -> String {
        guard var t = Decimal(string: des) else {
            return ""
        }
        var r = Decimal()
        NSDecimalRound(&r, &t, scale, .down)
        return String(describing: r)
    }

    static var df: DateFormatter {
        let df = DateFormatter()
        df.timeZone = .current
        df.locale = .current
        df.dateFormat = "HH:mm:ss"
        return df
    }
}

struct MarketList: View {
    @EnvironmentObject var ws: WS
    @State var data = ["market"]

    func row(_ time: String, _ price: String, _ quantity: String, _ c1: Color = .rowWhite, _ c2: Color = .headerGray, _ c3: Color = .rowWhite) -> some View {
        HStack {
            Text(time).foregroundColor(c1).padding(5)
            HStack() {
                Text(price).foregroundColor(c2).padding(5)
                Spacer()
                Text(quantity).foregroundColor(c3).frame(alignment: .trailing).padding(5)
            }
        }
    }

    var header: some View {
        HStack {
            Text("Time").foregroundColor(.headerGray).padding(5)
            HStack() {
                Text("Price").foregroundColor(.headerGray).padding(5).offset(x: 25)
                Spacer()
                Text("Currently").foregroundColor(.headerGray).frame(alignment: .trailing).padding(5)
            }
        }
    }

    func toRow(_ item: MarketItem) -> some View {
        row(item.time, item.price, item.quantity, .rowWhite, item.priceColor, .rowWhite)
    }

    var body: some View {
        VStack(spacing: 0) {
            header.background(Color.black).listRowBackground(Color.black).padding()
            List {
                ForEach(ws.tradeList) { item in
                    self.toRow(item)
                }.listRowBackground(Color.black)
            }
            Spacer()
        }.background(Color.black)
    }
}

struct MarketList_Previews: PreviewProvider {
    static var previews: some View {
        MarketList()
    }
}
