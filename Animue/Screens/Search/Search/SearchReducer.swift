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
        
    @Dependency(\.mainQueue) private var mainQueue
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
            
        case .pageAdded:
            
            state.page += 1
            
            return searchEffect(state)
            
        case let .queryChanged(query):
            
            state.searchQuery = query
            
            if query.isEmpty {
                state.results.removeAll()
                
                return .cancel(id: CancelID.network)
            }
            
            return searchEffect(state)
            
        case let .networkResponse(.success(anime)):
            
            state.results.append(contentsOf: anime)
                        
            return .none
            
        case let .networkResponse(.failure(error)):
            
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
        var searchQuery: String = ""
        var page: Int = 1
        var error: AnimeError? = nil
    }
}

// MARK: - Action
extension SearchReducer {
    enum Action {
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
