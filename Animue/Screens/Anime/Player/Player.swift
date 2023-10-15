//
//  Player.swift
//  Animue
//
//  Created by Artem Raykh on 15.10.2023.
//

import Foundation
import ComposableArchitecture
import AVFoundation

struct Player: Reducer {
    
    @Dependency(\.videoDatabaseManager) private var databaseManager
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .load(id, url):
            
            let item = AVPlayerItem(url: url)
            
            state.player.replaceCurrentItem(with: item)
            
            return .run { send in
                await send(
                    .loadResponse(
                        TaskResult { try await databaseManager.load(id) }
                    )
                )
            }
            
        case let .loadResponse(.success(time)):
            
            let time = CMTime(seconds: time, preferredTimescale: 60000)
            
            state.player.seek(to: time)
            
            return .none
            
        case let .save(id):
            
            let time = state.player.currentTime().seconds
            
            return .run { send in
                await send(.saveResponse(TaskResult { try await databaseManager.save(id, time)}))
            }
            
        case let .handle(error):
            
            state.error = AnimeError(error: error)
            
            return .none
            
        case let .loadResponse(.failure(error)):
            
            return .send(.handle(error: error))
            
        case .saveResponse(.success(())):
            
            return .none
            
        case let .saveResponse(.failure(error)):
            
            return .send(.handle(error: error))
        }
    }
}

extension Player {
    enum Action {
        case load(id: String, url: URL)
        
        case loadResponse(TaskResult<Double>)
        
        case save(id: String)
        
        case saveResponse(TaskResult<Void>)
        
        case handle(error: Error)
    }
}

extension Player {
    struct State: Equatable {
        let player: AVPlayer = AVPlayer()
        var error: AnimeError?
    }
}
