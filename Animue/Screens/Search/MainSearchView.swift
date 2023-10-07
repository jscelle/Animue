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
    var body: some View {
        
        VStack {
            searchView
            
            topAiring
            
            recentEpisodes
        }
        .padding()
        
    }
    
    @ViewBuilder
    private var searchView: some View {
        SeachView(
            store: Store(
                initialState: SearchReducer.State(),
                reducer: {
                    SearchReducer()
                }
            )
        )
    }
    
    @ViewBuilder
    private var topAiring: some View {
        Text("Top Airing")
            .font(.system(.title))
            .frame(maxWidth: .infinity, alignment: .leading)
        
        HorizontalListView(
            store: Store(
                initialState: HorizontalList.State(),
                reducer: {
                    withDependencies({
                        $0.horizontalListManager = .topAiring
                    }, operation: {
                        HorizontalList()
                    })
                }
            )
        )
    }
    
    @ViewBuilder
    private var recentEpisodes: some View {
        
        Text("Recent episodes")
            .font(.system(.title))
            .frame(maxWidth: .infinity, alignment: .leading)
        
        
        HorizontalListView(
            store: Store(
                initialState: HorizontalList.State(),
                reducer: {
                    withDependencies({
                        $0.horizontalListManager = .recentEpisodes
                    }, operation: {
                        HorizontalList()
                    })
                }
            )
        )
    }
}

struct MainSearchPreview: PreviewProvider {
    static var previews: some View {
        MainSearchView()
    }
}
