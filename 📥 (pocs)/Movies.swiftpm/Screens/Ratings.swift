//
//  File.swift
//  
//
//  Created by Cristian Felipe Patiño Rojas on 09/05/2024.
//

import SwiftUI

struct Ratings: View {
    @StateObject var ratings = FileBase.ratings
    var body: some View {
        Movies.List(data: ratings.items)
    }
}
