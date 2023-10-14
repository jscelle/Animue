//
//  MainSearchTests.swift
//  AnimueTests
//
//  Created by Artem Raykh on 08.10.2023.
//

import ComposableArchitecture
import XCTest
@testable import Animue

@MainActor
final class MainSearchReducerTests: XCTestCase {
    
    // Test the behavior when showing/hiding search
    func testShowSearch() async {
        
        let error = MockError()
        
        let store = TestStore(initialState: MainSearchReducer.State()) {
            MainSearchReducer()
                .dependency(\.mainQueue, .main)
                .dependency(\.horizontalListManager, .mock)
                .dependency(\.searchManager, .init(search: { _, _ in throw error }))
        }
        
        await store.send(.search(.queryChanged("New query"))) { state in
            state.searchState.searchQuery = "New query"
        }
        
        await store.receive(/MainSearchReducer.Action.showSearch(true)) { state in
            state.showsSearch = true
        }
        
        await store.receive(/MainSearchReducer.Action.search(.networkResponse(.failure(error)))) { state in
            state.searchState.error = AnimeError(error: error)
        }
        
        await store.finish()
    }
    
    func testSearchDidSelect() async {
        
        let mockAnime = Anime(
            id: UUID().uuidString,
            title: "Title",
            image: Mock.images.randomElement()!
        )
        
        let store = TestStore(initialState: MainSearchReducer.State()) {
            MainSearchReducer()
                .dependency(\.mainQueue, .main)
                .dependency(\.horizontalListManager,
                    .init(
                        load: { page in [] }
                    )
                )
                .dependency(\.animeDatabaseManager,
                    .init(
                        save: { _ in },
                        fetchAll: { [mockAnime] },
                        delete: { _ in },
                        deleteAll: { }
                    )
                )
        }
        
        // Selecting an anime in via search
        await store.send(.search(.didSelect(mockAnime)))
        
        await store.receive(
            /MainSearchReducer.Action.didSelect(mockAnime)
        )
        
        // Recetly visited updates
        await store.receive(/MainSearchReducer.Action.recentlyVisited(.load))
        
        // Recently shown gets data from database
        await store.receive(
            /MainSearchReducer.Action.recentlyVisited(
                .dataResponse(.success(([])))
            )
        )
        
        await store.receive(/MainSearchReducer.Action.recentlyVisited(.load))
        
        await store.receive(
            /MainSearchReducer.Action.recentlyVisited(.dataResponse(.success([mockAnime])))
        ) { state in
            state.recentlyVisited.recentlyWatched = [mockAnime]
        }
                
        await store.finish()
    }
    
    func testHorizontalListDidSelect() async {
        
        let mockAnime = Anime(
            id: UUID().uuidString,
            title: "Title",
            image: Mock.images.randomElement()!
        )
        
        let store = TestStore(initialState: MainSearchReducer.State()) {
            MainSearchReducer()
                .dependency(\.mainQueue, .main)
                .dependency(\.horizontalListManager, 
                    .init(
                        load:  { page in [] }
                    )
                )
                .dependency(\.animeDatabaseManager,
                    .init(
                        save: { _ in },
                        fetchAll: { [] },
                        delete: { _ in },
                        deleteAll: { }
                    )
                )
        }
        
        // Selecting an anime in via one of horizontal lists
        await store.send(.recentEpisodes(.didSelect(mockAnime)))
        
        // MainReducer getting anime id
        await store.receive(/MainSearchReducer.Action.didSelect(mockAnime))
        
        // Recently shown saves data to database
        await store.receive(/MainSearchReducer.Action.recentlyVisited(.save(anime: mockAnime)))
        
        // Database save complete
        await store.receive(/MainSearchReducer.Action.recentlyVisited(.emptyResponse(.success(()))))
        
        // Recenly loads updates
        await store.receive(/MainSearchReducer.Action.recentlyVisited(.load))
        
        // Recenly gets recently loaded items
        await store.receive(/MainSearchReducer.Action.recentlyVisited(.dataResponse(.success([]))))
        
        await store.finish()
    }
}

fileprivate struct MockError: Error { }
