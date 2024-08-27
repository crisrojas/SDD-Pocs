//
//  List.swift
//  
//
//  Created by Cristian Felipe Patiño Rojas on 10/04/2024.
//

import SwiftUI

struct Movies: View, NetworkGetter {
    
    @State var state = ResourceState.loading
    @State var loadingMore = false
    @State var page = 1
    
    let url: URL
    
    var currentURL: URL {
        url.appendingQueryItem("page", value: page)
    }
    
    var body: some View {_body}
    
    @ViewBuilder
    var _body: some View {
        switch state {
        case .loading: ProgressView().task { await loadData() }
        case .success(let data): successView(data.array)
        case .error(let error): error
        }
    }
    
    func loadData() async {
        do {
            let (data, _) = try await fetchData(url: currentURL)
            let json = try JSON(data: data)
            if state.isSuccess {
                state.appendData(json.results)
            } else {
                state = .success(json.results)
            }
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func successView(_ data: [JSON]) -> some View {
        List(
            data: data,
            cellTask: { await loadMoreIfNeeded(data, movie: $0) }
        )
    }
    
    func loadMoreIfNeeded(_ data: [JSON], movie: JSON) async {
        if movie.id == data.last?.id {
            page += 1
            await loadData()
        }
    }
}


extension Movies {
    struct List: View {
        
        let data: [JSON]
        var cellTask: (JSON) async -> Void = { _ in }
        
        typealias List = SwiftUI.List
        
        var body: some View {
            // Use id instead of self so navigation
            // isn't recomputed if we make a change to the item
            // (List will detect it as a different item and remake cells thus destroying current navigation if we're on detail)
            // @todo: not working on real device
            List(data, id: \.id) { movie in
                Cell(props: movie)
                    .onTap(navigateTo: Movie(props: movie))
                    .task { await cellTask(movie) }
            }
            .modify {
                if #available(iOS 16.0, *) {
                    $0.scrollContentBackground(.hidden)
                }
            }
            .background(DefaultBackground().fullScreen())
        }
    }
}

extension Movies.List {
    struct Cell: View {
        
        @Environment(\.theme) var theme: Theme
        let title: String
        let posterURL: URL?
        let overview: String
        
        var body: some View {
            
            HStack(spacing: .s4) {
         
                AsyncImage(url: posterURL) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray.opacity(0.3)
                        .overlay(ProgressView())
                }
                .cornerRadius(4)
                .width(70)
                .height(100)
                
                VStack(alignment: .leading, spacing: .s1) {
                    
                    Text(title)
                        .foregroundColor(theme.textPrimary)
                        .fontWeight(.heavy)
                        .font(.system(.headline, design: .rounded))
                        .lineLimit(2)

                    VStack(alignment: .leading) {
                        
                        Text(overview.prefix(90) + "...")
                            .fontWeight(.bold)
                            .lineLimit(3)
                    }
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(theme.textPrimary)
                    
                }
                
                Spacer()
            }
        }
    }
}

extension Movies.List.Cell {
    init(props: JSON)  {
        title = props.title
        posterURL = props.poster_path.string?.tmdbImageURL
        overview = props.overview
    }
}
