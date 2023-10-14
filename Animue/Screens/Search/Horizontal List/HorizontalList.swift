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
                    .dataResponse(TaskResult { try await manager.load(page) })
                )
            }
            .cancellable(id: CancelID.network)
            
        
            
        case .pageAdded:
            
            state.page += 1
            
            return .run { [page = state.page] send in
                await send(
                    .dataResponse(TaskResult { try await manager.load(page) })
                )
            }
            .cancellable(id: CancelID.network)
            
        case let .dataResponse(.success(items)):
            
            state.items.append(contentsOf: items)
            
            return .none
            
        case let .dataResponse(.failure(error)):
            
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
        
        case dataResponse(TaskResult<[Anime]>)
        case didSelect(Anime)
    }
}

extension HorizontalList {
    private enum CancelID {
        case network
    }
}
