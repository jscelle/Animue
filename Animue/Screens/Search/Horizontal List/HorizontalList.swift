//
//  TopAiringScreen.swift
//  Animue
//
//  Created by Artem Raykh on 07.10.2023.
//

import Foundation
import ComposableArchitecture

struct HorizontalList: Reducer {
    
    @Dependency(\.horizontalListManager) private var manager
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
            
        case .initialLoad:
            
            return .run { [page = state.page] send in
                await send(
                    .networkResponse(TaskResult { try await manager.load(page) })
                )
            }
            .cancellable(id: CancelID.network)
            
        case .pageAdded:
            
            state.page += 1
            
            return .run { [page = state.page] send in
                await send(
                    .networkResponse(TaskResult { try await manager.load(page) })
                )
            }
            .cancellable(id: CancelID.network)
            
        case .networkResponse(.success(let items)):
            state.items.append(contentsOf: items)
            return .none
        case .networkResponse(.failure(let error)):
            state.error = AnimeError(error: error)
            
            return .none
            
        case .didSelect:
            return .none
        }
    }
}

extension HorizontalList {
    struct State: Equatable {
        var items: [Anime] = []
        var error: AnimeError? = nil
        var page: Int = 1
    }
}

extension HorizontalList {
    enum Action {
        case initialLoad
        case pageAdded
        case networkResponse(TaskResult<[Anime]>)
        case didSelect(Anime)
    }
}

extension HorizontalList {
    private enum CancelID {
        case network
    }
}
