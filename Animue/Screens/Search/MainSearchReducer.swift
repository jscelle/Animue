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
        
        Scope(
            state: \.recentlyVisited,
            action: /Action.recentlyVisited,
            child: {
                RecentlyVisited()
            }
        )
        
        Reduce { state, action in
            switch action {
            case .search(.queryChanged(let query)):
                
                return .send(.showSearch(!query.isEmpty), animation: .spring())
                
            case let .showSearch(showSearch):
                
                state.showsSearch = showSearch
                
                return .none

            case let .search(.didSelect(anime)),
                    let .topAiring(.didSelect(anime)),
                    let .recentEpisodes(.didSelect(anime)),
                    let .recentlyVisited(.didSelect(anime)):
                
                return .send(.didSelect(anime))
                
            case let .didSelect(anime):
                
                return .send(.recentlyVisited(.save(anime: anime)))
                
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
        var recentlyVisited = RecentlyVisited.State()
    }
}

extension MainSearchReducer {
    enum Action {
        case didSelect(Anime)
        case showSearch(Bool)
        case handleError(Error)
        case search(SearchReducer.Action)
        case topAiring(HorizontalList.Action)
        case recentEpisodes(HorizontalList.Action)
        case recentlyVisited(RecentlyVisited.Action)
    }
}
