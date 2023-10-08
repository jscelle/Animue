//
//  MainSearchReducer.swift
//  Animue
//
//  Created by Artem Raykh on 08.10.2023.
//

import Foundation
import ComposableArchitecture
import Dependencies

struct MainSearchReducer: Reducer {
    
    @Dependency(\.animeDatabaseManager) private var databaseManager
    
    var body: some Reducer<State, Action> {
        
        Scope(
            state: \.searchState,
            action: /Action.search,
            child: {
                SearchReducer()
            }
        )
        
        Scope(
            state: \.topAiringState,
            action: /Action.topAiring,
            child: {
                withDependencies { 
                    $0.horizontalListManager = .topAiring
                } operation: {
                    HorizontalList()
                }
            }
        )
        
        Scope(
            state: \.recentEpisodes,
            action: /Action.recentEpisodes,
            child: {
                withDependencies {
                    $0.horizontalListManager = .recentEpisodes
                } operation: {
                    HorizontalList()
                }
            }
        )
        
        Reduce { state, action in
            switch action {
            case .search(.queryChanged(let query)):
                
                return .send(.showSearch(!query.isEmpty), animation: .spring())
                
            case .showSearch(let showSearch):
                
                state.showsSearch = showSearch
                
                return .none
                
            case .search(.didSelect(let anime)), .topAiring(.didSelect(let anime)), .recentEpisodes(.didSelect(let anime)):
                
                return .merge(
                    .run { send in
                        await send(
                            .didSelect(anime.id)
                        )
                    },
                    .run { send in
                        await send(
                            .didSaved(TaskResult { try await databaseManager.save(anime) })
                        )
                    },
                    .run { send in
                        await send(
                            .search(.loadRecent)
                        )
                    }
                )
                
            default:
                return .none
            }
        }
    }
}

extension MainSearchReducer {
    struct State: Equatable {
        var showsSearch = false
        var searchState = SearchReducer.State()
        var topAiringState = HorizontalList.State()
        var recentEpisodes = HorizontalList.State()
    }
}

extension MainSearchReducer {
    enum Action {
        case didSelect(String)
        case didSaved(TaskResult<Void>)
        case showSearch(Bool)
        case handleError(Error)
        case search(SearchReducer.Action)
        case topAiring(HorizontalList.Action)
        case recentEpisodes(HorizontalList.Action)
    }
}
