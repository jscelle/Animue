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
        
        VStack {
            textField
                    
            list
        }
    }
    
    private var textField: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack {
                
                if viewStore.state.searchQuery.isEmpty {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(.leading, 12)
                }
                
                TextField(
                    "Search",
                    text: viewStore.binding(
                        get: \.searchQuery,
                        send: { .queryChanged($0) }
                    )
                )
                .padding(12)
                .shadow(radius: 2)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            }
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
    
    private var list: some View {
        
        WithViewStore(store, observe: { $0 }) { viewStore in
            if !viewStore.searchQuery.isEmpty {
                
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
                                .onTapGesture {
                                    viewStore.send(
                                        .didSelect(
                                            Anime(
                                                id: anime.id,
                                                title: anime.title,
                                                image: anime.image
                                            )
                                        )
                                    )
                                }
                        }
                    }
                }
            }
        }
    }
}

struct Search_Preview: PreviewProvider {
    static var previews: some View {
        SeachView(
            store: Store(initialState: SearchReducer.State(), reducer: {
                SearchReducer()
            })
        )
        .preferredColorScheme(.dark)
    }
}
