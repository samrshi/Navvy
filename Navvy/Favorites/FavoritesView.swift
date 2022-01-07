//
//  FavoritesView.swift
//  Navvy
//
//  Created by Samuel Shi on 1/6/22.
//

import SwiftUI

struct FavoritesView: View {
    @State private var favorites: [Destination] = []
    
    var body: some View {
        List {
            ForEach(favorites) { destination in
                Text(destination.name ?? "Unknown xxxxxx")
            }
            .onDelete { indexSet in
                for index in indexSet {
                    let destination = favorites[index]
                    FavoritesDataStore.shared.remove(destination: destination)
                    favorites = FavoritesDataStore.shared.getAll()
                }
            }
        }
        .onAppear {
            favorites = FavoritesDataStore.shared.getAll()
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
    }
}
