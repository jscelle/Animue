//
//  RecentlyVisitedView.swift
//  Animue
//
//  Created by Artem Raykh on 14.10.2023.
//

import ComposableArchitecture
import SwiftUI

struct RecentlyVisitedView: View {
    
    let store: StoreOf<RecentlyVisited>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView([.horizontal], showsIndicators: false) {
                
                LazyHStack {
                    ForEach(viewStore.state.recentlyWatched, id: \.id) { item in
                        HorizontalItemView(item: item)
                            .onTapGesture {
                                viewStore.send(
                                    .didSelect(
                                        anime: Anime(
                                            id: item.id,
                                            title: item.title,
                                            image: item.image
                                        )
                                    )
                                )
                            }
                            .onLongPressGesture {
                                
                            }
                    }
                }
                .onAppear {
                    viewStore.send(.load)
                }
            }
        }
    }
}

struct RecentlyVisitedPreview: PreviewProvider {
    static var previews: some View {
        RecentlyVisitedView(
            store: Store(
                initialState: RecentlyVisited.State(),
                reducer: {
                    RecentlyVisited()
            })
        )
    }
}
