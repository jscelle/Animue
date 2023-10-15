//
//  PlayerView.swift
//  Animue
//
//  Created by Artem Raykh on 15.10.2023.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import AVKit

struct PlayerView: View  {
    
    let episodeId: String
    
    let url: URL
    
    let store: StoreOf<Player>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VideoExtractingWebView(url: url) { result in
                switch result {
                case let .success(url):
                    viewStore.send(.load(id: episodeId, url: url))
                case let .failure(error):
                    viewStore.send(.handle(error: error))
                }
            }
            .frame(width: .zero, height: .zero)
            
            VideoPlayer(player: viewStore.player)
        }
    }
}
 
struct PlayerPreview: PreviewProvider {
    static var previews: some View {
        PlayerView(
            episodeId: "the-idolmster-million-live-episode-2",
            url: URL(string: "https://alions.pro/v/c1bbwn2fj3nu")!,
            store: Store(
                initialState: Player.State(),
                reducer: {
                    Player()
                }
            )
        )
    }
}
