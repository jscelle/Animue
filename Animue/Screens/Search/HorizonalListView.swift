//
//  TopAiringView.swift
//  Animue
//
//  Created by Artem Raykh on 07.10.2023.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct HorizontalListView: View {
    
    let store: StoreOf<HorizontalList>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView([.horizontal], showsIndicators: false) {
                
                LazyHStack {
                    ForEach(viewStore.state.items, id: \.id) { item in
                        HorizontalItemView(item: item)
                            .onAppear {
                                if item == viewStore.state.items.last {
                                    viewStore.send(.pageAdded)
                                }
                            }
                    }
                }
            }
            
            .onAppear {
                viewStore.send(.pageAdded)
            }
        }
    }
}

struct HorizontalItemView: View {
    let item: HorizontalListItem
    
    var body: some View {
        VStack {
            CachedAsyncImage(url: item.image, urlCache: .shared) { image in
                
                GeometryReader { geometry in
                    image
                        .resizable()
                        .scaledToFill()
                        .clipped()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            } placeholder: {
                Color.gray
            }
            
            Text(item.title)
                .font(.system(.title2))
                .foregroundStyle(.white)
                .padding()
        }
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct HorizonalListPreview: PreviewProvider {
    static var previews: some View {
        HorizontalListView(
            store: Store(
                initialState: HorizontalList.State(),
                reducer: {
                    HorizontalList()
            })
        )
    }
}
