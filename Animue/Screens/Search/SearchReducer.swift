//
//  SearchReducer.swift
//  Animue
//
//  Created by Artem Raykh on 02.10.2023.
//

import Foundation
import ComposableArchitecture

struct Search: Reducer {
        
    @Dependency(\.networkManager) private var networkManager
    
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
                
                return .cancel(id: CancelID.anime)
            }
            
            return searchEffect(state)
            
        case .networkResponse(.success(let anime)):
            state.results = anime
            
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
                    TaskResult { try await networkManager.search(query: query, page: page) }
                )
            )
        }
        .debounce(id: CancelID.anime, for: 0.2, scheduler: mainQueue)
        .cancellable(id: CancelID.anime)
    }
}

// MARK: - State
extension Search {
    struct State: Equatable {
        var results: [Anime] = []
        var searchQuery: String = ""
        var page: Int = 1
        var error: AnimeError? = nil
    }
}

// MARK: - Action
extension Search {
    enum Action {
        case pageAdded
        case queryChanged(String)
        case networkResponse(TaskResult<[Anime]>)
    }
}

// MARK: - CancelId's
private extension Search {
    enum CancelID {
        case anime
    }
}
