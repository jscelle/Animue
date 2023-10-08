//
//  Search.swift
//  Animue
//
//  Created by Artem Raykh on 02.10.2023.
//

import Foundation
import ComposableArchitecture

struct SearchReducer: Reducer {
    
    @Dependency(\.searchManager) private var networkManager
    
    @Dependency(\.animeDatabaseManager) private var databaseManager
    
    @Dependency(\.mainQueue) private var mainQueue
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
            
        case .loadRecent:
            
            return .run { send in
                await send(
                    .databaseResponse(
                        TaskResult{ try await databaseManager.fetchAll() }
                    )
                )
            }
            
        case .databaseResponse(.failure(let error)):
            state.error = AnimeError(error: error)
            
            return .none
        case .databaseResponse(.success(let anime)):
            
            state.recent = anime
            
            return .none
            
        case .deleteRecent(let id):
            
            return .run { [recent = state.recent] send in
                await send(
                    .databaseResponse(TaskResult {
                        try await databaseManager.delete(id)
                        
                        var recent = recent
                        recent.removeAll { $0.id == id }
                        
                        return recent
                    })
                )
            }
            
        case .pageAdded:
            
            state.page += 1
            
            return searchEffect(state)
            
        case .queryChanged(let query):
            
            state.searchQuery = query
            
            if query.isEmpty {
                state.results.removeAll()
                
                return .cancel(id: CancelID.network)
            }
            
            return searchEffect(state)
            
        case .networkResponse(.success(let anime)):
            
            state.results.append(contentsOf: anime)
            
            state.recent.removeAll()
            
            return .none
        case .networkResponse(.failure(let error)):
            state.error = AnimeError(error: error)
            
            return .none
        case .didSelect:
            
            return .none
        }
    }
    
    private func searchEffect(_ state: State) -> Effect<Action> {
        .run { [query = state.searchQuery, page = state.page] send in
            await send(
                .networkResponse(
                    TaskResult { try await networkManager.search(query, page) }
                )
            )
        }
        .debounce(id: CancelID.network, for: 0.2, scheduler: mainQueue)
        .animation(.spring)
        .cancellable(id: CancelID.network)
    }
}

// MARK: - State
extension SearchReducer {
    struct State: Equatable {
        var results: Array<AnimeSearchDTO> = .init()
        var recent: Array<Anime> = .init()
        var searchQuery: String = ""
        var page: Int = 1
        var error: AnimeError? = nil
    }
}

// MARK: - Action
extension SearchReducer {
    enum Action {
        case loadRecent
        case databaseResponse(TaskResult<[Anime]>)
        case deleteRecent(String)
        case pageAdded
        case queryChanged(String)
        case networkResponse(TaskResult<[AnimeSearchDTO]>)
        case didSelect(Anime)
    }
}

// MARK: - CancelId's
private extension SearchReducer {
    enum CancelID {
        case network
        case database
    }
}
