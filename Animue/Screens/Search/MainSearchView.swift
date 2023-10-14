//
//  MainSearchView.swift
//  Animue
//
//  Created by Artem Raykh on 07.10.2023.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import Dependencies

struct MainSearchView: View {
    
    let store: StoreOf<MainSearchReducer>
    
    var body: some View {
        
        WithViewStore(store, observe: { $0 }) { viewStore in
            
            ScrollView {
                VStack {
                    searchView
                    
                    if !viewStore.state.showsSearch {
                        topAiring
                        
                        recentEpisodes
                        
                        recenlyVisited
                    }
                }
                .padding()
            }
        }
    }
    
    @ViewBuilder
    private var searchView: some View {
        SeachView(
            store: store.scope(
                state: \.searchState,
                action: MainSearchReducer.Action.search
            )
        )
    }
    
    @ViewBuilder
    private var topAiring: some View {
        Text("Top Airing")
            .font(.system(.title))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(.white)
        
        HorizontalListView(
            store: store.scope(
                state: \.topAiringState,
                action: MainSearchReducer.Action.topAiring
            )
        )
    }
    
    @ViewBuilder
    private var recentEpisodes: some View {
        
        Text("Recent episodes")
            .font(.system(.title))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(.white)
        
        
        HorizontalListView(
            store: store.scope(
                state: \.recentEpisodes,
                action: MainSearchReducer.Action.recentEpisodes
            )
        )
    }
    
    @ViewBuilder
    private var recenlyVisited: some View {
        Text("Recently visited")
            .font(.system(.title))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(.white)
        
        RecentlyVisitedView(
            store: store.scope(
                state: \.recentlyVisited,
                action: MainSearchReducer.Action.recentlyVisited
            )
        )
    }
}

struct MainSearchPreview: PreviewProvider {
    static var previews: some View {
        MainSearchView(
            store: Store(
                initialState: MainSearchReducer.State(),
                reducer: {
                    MainSearchReducer()
                        .dependency(\.horizontalListManager, .previewValue)
                }
            )
        )
        .preferredColorScheme(.dark)
    }
}
