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
    
    
    private let store: StoreOf<SearchReducer>
    
    init(store: StoreOf<SearchReducer>) {
        self.store = store
    }
    
    var body: some View {
        
        WithViewStore(store, observe: { $0 }) { viewStore in
            
            VStack {
                textField(
                    text: viewStore.binding(
                        get: \.searchQuery,
                        send: { .queryChanged($0) }
                    )
                )
                
                ScrollView {
                    
                    LazyVGrid(
                        columns: [
                            .init(.flexible())
                        ]
                    ) {
                        ForEach(viewStore.state.results, id: \.id) { anime in
                            AnimeView(anime: anime)
                                .onAppear {
                                    if anime == viewStore.state.results.last {
                                        viewStore.send(.pageAdded)
                                    }
                                }
                        }
                    }
                }
            }
        }
    }
    
    private func textField(text: Binding<String>) -> some View {
        
        HStack {
            if text.wrappedValue.isEmpty {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(.leading, 12) // Adjust the spacing here
            }
            
            TextField("Search", text: text)
                .padding(12)
                .shadow(radius: 2)
                .foregroundColor(.white) // White text color
                .padding(.horizontal, 20)
        }
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct Search_Preview: PreviewProvider {
    static var previews: some View {
        SeachView(
            store: Store(initialState: SearchReducer.State(), reducer: {
                SearchReducer()
            })
        )
    }
}

struct AnimeView: View {
    
    let anime: Anime
    
    var body: some View {
        VStack {
            CachedAsyncImage(url: anime.image, urlCache: .shared) { image in
                image
                    .resizable()
                    .scaledToFill()
                
            } placeholder: {
                Color.gray
            }
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 25,
                    style: .continuous
                )
            )
            
            Text(anime.title)
        }
    }
}
