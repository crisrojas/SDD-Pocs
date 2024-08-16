//
//  ContentView.swift
//  Exchange
//
//  Created by JimLai on 2020/2/27.
//  Copyright © 2020 stargate. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State var selected = 0
    @EnvironmentObject var shared: SharedState
    @EnvironmentObject var ws: WS
    
    var titles = ["Order Book", "Market History"]
    
    var customAlert: some View {
        GeometryReader { geo in
            VStack(spacing: 20) {
                Text("The Internet connection appears to be offline")
                    .foregroundColor(.white)
                    .padding()
                
                Button(action: {self.ws.showNetworkAlert.toggle()}) {
                    Text("OK")
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                    
                }
                .background(Color.yellow)
                .foregroundColor(.black)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.tabGray)
            )
            .frame(width: geo.size.width * 0.8, height: geo.size.height * 0.25)
        }
    }
    var contentView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(0..<titles.count) { index in
                    if index == self.selected {
                        Button(self.titles[index]) {
                            self.selected = index
                        }
                        .background(Color.black)
                        .foregroundColor(.textYellow)
                        .padding()
                        .overlay(
                            Rectangle()
                                .fill(Color.yellow)
                                .frame(width: 40, height: 2)
                                .offset(x: 0, y: 20)
                        )
                    } else {
                        Button(self.titles[index]) {
                            self.selected = index
                        }
                        .background(Color.black)
                        .foregroundColor(.tabGray)
                        .padding()
                    }
                }
            }
            
            if selected == 0 {
                OrderList().transition(.slide)
            } else {
                MarketList().transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
            
            Spacer()

        }
        .frame(maxWidth: .infinity)
        .background(Color.black)
        .edgesIgnoringSafeArea(.bottom)
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.top)
            if ws.showNetworkAlert {
                contentView.overlay(customAlert)
            } else {
                contentView
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
