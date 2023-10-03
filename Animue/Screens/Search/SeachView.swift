//
//  SeachView.swift
//  Animue
//
//  Created by Artem Raykh on 03.10.2023.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct SeachView: View {
    
    
    private let store: StoreOf<Search>
    
    init(store: StoreOf<Search>) {
        self.store = store
    }
    
    var body: some View {
        
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                TextField(
                    "Search for anime",
                    text: viewStore.binding(
                        get: \.searchQuery,
                        send: { .queryChanged($0) }
                    )
                )
                
                Text("Text is \(viewStore.state.results.count)")
                
                Text("Error is \(String(describing: viewStore.state.error))")
                
                ForEach(viewStore.state.results, id: \.id) { anime in
                    AnimeView(anime: anime)
                }
            }
        }
    }
}

struct Search_Preview: PreviewProvider {
    static var previews: some View {
        SeachView(
            store: Store(initialState: Search.State(), reducer: {
                Search()
            })
        )
    }
}

struct AnimeView: View {
    
    let anime: Anime
    
    var body: some View {
        VStack {
            CachedAsyncImage(url: URL(string: anime.url)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray
            }
            .clipShape(.capsule)
            
            Text(anime.title)
        }
    }
}
