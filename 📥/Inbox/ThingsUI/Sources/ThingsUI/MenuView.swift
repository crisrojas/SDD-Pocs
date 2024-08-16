//
//  File.swift
//  
//
//  Created by Cristian Felipe Patiño Rojas on 09/05/2023.
//

import SwiftUI

struct MenuView: View {
    
    let projects: [Project]
    
    var body: some View {
        ScrollView {
            VStack(spacing: .sizing(1)) {
                
                    itemLink(.inbox, inbox)
                        .padding(.top, .sizing(16))
                    itemLink(.today, today)
                    itemLink(.planned, planned)
                    itemLink(.anytime, anytime)
                    itemLink(.someDay, someday)
                    itemLink(.history, history)
                
                Divider()
                    .background(Color.systemGray)
                    .padding(.vertical, .sizing(4))
                
                ProjectRow(editing: false)
                    .navLinkify(destination: dummyProj)
                    .buttonStyle(MenuItemStyle())
                

            }
            .padding(.horizontal, .sizing(2))
        }
        .overlay(quickFindBar, alignment: .top)
        .overlay(statusBar, alignment: .top)
    }
    
    private var quickFindBar: some View {
        QuickSearchField()
            .padding(.horizontal, .sizing(2))
    }
    
    private var dummyProj: some View {
        Text("@todo")
    }
    
    private var statusBar: some View {
        Rectangle()
            .frame(height: .statusBarHeight ?? 40)
            .foregroundColor(.systemBackground)
            .edgesIgnoringSafeArea(.top)
    }
    
    private var inbox: some View { Text("inbox") }
    private var today: some View { Text("inbox") }
    private var planned: some View { Text("inbox") }
    private var anytime: some View { Text("inbox") }
    private var someday: some View { Text("inbox") }
    private var history: some View { Text("inbox") }
    private var trash: some View { Text("inbox") }
    
    func itemLink<D: View>(_ model: MenuItem, _ destination: D) -> some View {
        NavigationLink(
            destination: destination,
            label: {MenuRow(model: model)}
        )
        .buttonStyle(MenuItemStyle())
    }
}
