//
//  RecentlyVisited.swift
//  Animue
//
//  Created by Artem Raykh on 13.10.2023.
//

import ComposableArchitecture

struct RecentlyVisited: Reducer {
    
    @Dependency(\.animeDatabaseManager) private var databaseManager
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
            
        case let .save(anime):
            
            if !state.recentlyWatched.contains(anime) {
                return .run { send in
                    await send(
                        .emptyResponse(TaskResult {
                            try await databaseManager.save(anime)
                        })
                    )
                }
            }
            
            return .none
            
        case .load:
            return .run { send in
                await send(
                    .dataResponse(TaskResult {
                        try await databaseManager.fetchAll()
                    })
                )
            }
            
        case let .delete(id):
            
            if state.recentlyWatched.map({ $0.id }).contains(id) {
                return .run { send in
                    await send(
                        .emptyResponse(TaskResult {
                            try await databaseManager.delete(id)
                        })
                    )
                }
            }
            
            return .none
            
        case .deleteAll:
            return .run { send in
                await send(
                    .emptyResponse(TaskResult {
                        try await databaseManager.deleteAll()
                    })
                )
            }
            
        case let .dataResponse(.success(recentlyWatched)):
            state.recentlyWatched = recentlyWatched
            return .none
            
        case let .dataResponse(.failure(error)):
            state.error = AnimeError(error: error)
            return .none
            
        case .emptyResponse(.success(())):
            
            return .send(.load)
            
        case let .emptyResponse(.failure(error)):
            state.error = AnimeError(error: error)
            
            return .none
            
        case .didSelect:
            return .none
        }
    }
}

extension RecentlyVisited {
    enum Action {
        case load
        case delete(String)
        case deleteAll
        
        case save(anime: Anime)
        case emptyResponse(TaskResult<Void>)
        
        case dataResponse(TaskResult<[Anime]>)
        
        case didSelect(anime: Anime)
    }
}

extension RecentlyVisited {
    struct State: Equatable {
        var recentlyWatched: [Anime] = []
        var error: AnimeError?
    }
}
