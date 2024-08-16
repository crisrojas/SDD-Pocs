//
//  Websocket.swift
//  Exchange
//
//  Created by JimLai on 2020/2/29.
//  Copyright © 2020 stargate. All rights reserved.
//

import SwiftUI
import Starscream
import Combine
import Network


final class WS: ObservableObject {

    
    @Published var orderRows = [OrderRow]()
    @Published var showNetworkAlert = false
    @Published var decimalPlaces: Int?
    @Published var tradeList = [MarketItem]()
    
    static var baseUrl = "wss://stream.binance.com:9443"
    static var ethusdt = "/ws/ethusdt"
    
    var tradeListBuffer = [MarketItem]()
    var tradeRefresh = false
    
    let tradeListLimit = 10
    let displayLimit = 20


    var snapshot = Json("https://www.binance.com/api/v1/depth?symbol=ETHUSDT&limit=20")

    var multiplier: Decimal {
        decimalPlaces == nil ? 1 : pow(10, decimalPlaces ?? 0)
    }

    var cancellable: AnyCancellable?
    
    var subscribe: String {
        let sub: [String: Any] = ["method": "SUBSCRIBE", "params": ["ethusdt@aggTrade", "ethusdt@depth"], "id": 8159]
        guard let data = try? JSONSerialization.data(withJSONObject: sub, options: .prettyPrinted), let s = String(bytes: data, encoding: .utf8) else {
            dp("subscribe failed")
            return ""
        }
        return s
    }
    
    var askBook = [Decimal: Decimal]()
    var asks: [DepthItem] {
        let items = getDepthItemList(from: askBook)
        return items.count < displayLimit ? Array(items) : Array(items[0 ..< displayLimit])
    }
    
    var bidBook = [Decimal: Decimal]()
    var bids: [DepthItem] {
        let items = Array(getDepthItemList(from: bidBook).reversed())
        return items.count < displayLimit ? items : Array(items[0 ..< displayLimit])
    }
    
    var newOrderRows: [OrderRow] {
        let a = asks
        let b = bids
        let sumA = a.reduce(into: 0.0) { $0 += $1.q}
        let sumB = b.reduce(into: 0.0) { $0 += $1.q}
        let zs = zip(a, b)
        return zs.map {OrderRow($0.0, $0.1, sumA, sumB)}
    }
    
    var buffer = [UID: JSON]()
   
    var socket: WebSocket {
        let url = URL(string: WS.baseUrl + WS.ethusdt)!
        var req = URLRequest(url: url)
        req.httpMethod = "get"
        let ws = WebSocket(request: req)
        return ws
    }
    let monitor = NWPathMonitor()
    
    var refreshInProgress = false
    var lastUpdateId: Int?
    
  

    init() {
        socket.delegate = self
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                dp("has network connection")
                self.showNetworkAlert = false
                self.open()
            } else {
                dp("no connection")
                self.noNetworkHandler()
            }
        }
        monitor.start(queue: DispatchQueue.global())
    }
}

extension WS {
    
    func noNetworkHandler() {
        showNetworkAlert = true
    }

    func reset() {
        buffer = [:]
        askBook = [:]
        bidBook = [:]
        lastUpdateId = nil
    }

    func open() {
        reset()
        socket.connect()
        cancellable = snapshot.onSuccess { json in
            dp(json)
            self.update(json)
        }.get()
    }
    func onDecimalPlaceChange(_ newDecimalPlace: Int) {
        decimalPlaces = newDecimalPlace
        orderRows = newOrderRows
    }
    
    func depthUpdate(_ j: JSON) {
        let uid = UID(U: j[P.U].intValue, u: j[P.u].intValue)
        guard let _ = lastUpdateId else {
            buffer[uid] = j
            return
        }
        
        for a in j[P.a].arrayValue {
            let v = a[1].decimalValue
            askBook[a[0].decimalValue] = v == 0 ? nil : v
        }
        for b in j[P.b].arrayValue {
            let v = b[1].decimalValue
            bidBook[b[0].decimalValue] = v == 0 ? nil : v
        }
        refresh()
    }
    
    func aggTrade(_ j: JSON) {
        //dp(j)
        var pc = Color.bidGreen
        if let last = tradeListBuffer.first, let lp = Decimal(string: last.price), let price = Decimal(string: j[P.p].stringValue) {
            pc = price < lp ? .askRed : .bidGreen
        }
        tradeListBuffer.insert(MarketItem(j, pc), at: 0)
        if tradeListBuffer.count > tradeListLimit {
            tradeListBuffer.removeLast()
        }
        guard tradeRefresh == false else {return}
        tradeRefresh = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.tradeList = self.tradeListBuffer
            self.tradeRefresh = false
        }
    }
    
    func round(_ de: Decimal) -> Decimal {
        var t = de
        var r = Decimal()
        NSDecimalRound(&r, &t, decimalPlaces ?? 4, .down)
        return r
    }


    func getDepthItemList(from book: [Decimal: Decimal]) -> [DepthItem] {
        let newBook = book.reduce(into: [Decimal: Decimal]()) { (r, kv) in
            let roundedKey = round(kv.key)
            r[roundedKey, default: 0.0] += kv.value
        }.mapValues { v in round(v)}
        return newBook.keys.sorted().map {DepthItem($0, newBook[$0, default: 0])}
    }
    
    
    func refresh() {
        if refreshInProgress == false {
            refreshInProgress = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.orderRows = self.newOrderRows
                //dp(self.orderRows)
                self.refreshInProgress = false
            }
        }
    }
    func update(_ json: JSON) {
        askBook = [:]
        bidBook = [:]
        decimalPlaces = 4
        for j in json[P.asks].arrayValue {
            askBook[j[0].decimalValue] = j[1].decimalValue
        }
        for j in json[P.bids].arrayValue {
            bidBook[j[0].decimalValue] = j[1].decimalValue
        }
        let lid = json[P.lastUpdateId].intValue
        lastUpdateId = lid
        for k in buffer.keys {
            guard k.isLater(than: lid) else {continue}
            for j in buffer[k]![P.asks].arrayValue {
                let price = j[0].decimalValue
                let q = j[1].decimalValue
                if askBook[price] == nil {
                    askBook[price] = q
                }
            }
            for j in buffer[k]![P.bids].arrayValue {
                let price = j[0].decimalValue
                let q = j[1].decimalValue
                if bidBook[price] == nil {
                    bidBook[price] = q
                }
            }
        }
        refresh()
    }

}

extension WS: WebSocketDelegate {
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("websocketDidReceiveData")
    }
    
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        print("didRreceive event")
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        dp("connected")
        socket.write(string: subscribe)
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        dp("disconnected")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        guard let data = text.data(using: .utf8), let json = try? JSONSerialization.jsonObject(with: data) else {
            return
        }
        let j = JSON(json)
        //dp(j)
        let e = j[P.e].stringValue
        switch e {
        case "aggTrade":
            aggTrade(j)
        case "depthUpdate":
            depthUpdate(j)
        default:
            dp(e)
            return
        }
    }
}
