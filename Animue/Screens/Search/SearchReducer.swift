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
            
        case .queryChanged(let query):
            
            state.searchQuery = query
            
            if query.isEmpty {
                state.results = []
                
                return .cancel(id: CancelID.network)
            }
            
            return searchEffect(state)
            
        case .networkResponse(.success(let anime)):
            state.results.append(contentsOf: anime)
            
            return .none
        case .networkResponse(.failure(let error)):
            state.error = AnimeError(error: error)
            
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
        var results: [Anime] = []
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
        case networkResponse(TaskResult<[Anime]>)
    }
}

// MARK: - CancelId's
private extension SearchReducer {
    enum CancelID {
        case network
    }
}
