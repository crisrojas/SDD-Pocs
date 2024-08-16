//
//  File.swift
//  
//
//  Created by Cristian Felipe Patiño Rojas on 10/04/2024.
//

import SwiftUI

struct Genres: View {
    
    var body: some View {
        AsyncJSON(url: TMDb.genres)  { response in
            List(response.genres.array, id: \.id) { genre in
                Text(genre.name)
                    .font(.system(.headline, design: .rounded))
                    .onTap(navigateTo: list(genre.id))
            }
            .background(DefaultBackground().fullScreen())
            .modify {
                if #available(iOS 16.0, *) {
                    $0.scrollContentBackground(.hidden)
                }
            }
        }
    }

    func list(_ id: Int) -> Movies {
        Movies(url: TMDb.genre(id: id))
    }
}

/*
 
 Wanted api
 
 <div id="recipes">
   <div object-id="1" class="recipe">
     <p property="title">Chicken tendori</p>
     <p property="price">30 usd</p>
   </div>
   <div object-id="2" class="recipe">
     <p property="title">Boeuf</p>
     <p property="price">28 usd</p>
   </div>
 </div>
 
 extension HTMLNode: Identifiable { 
     var id: String { attribute["object-id"] ?? "null" }
 }
 
 @dynamicMemberLookup
 extension HTMLNode { 
     subscript(dynamicMember member: String) -> Self? {
         subnodes.children.first { $0.attribute["property"] == member }
     }
 }
 
 AwaitHTML(url: "http://google.com") { html in
     List(html.recipes) { recipe in 
         Text(recipe.title)
     }
 }
 
 */
