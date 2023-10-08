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
}

fileprivate struct MockError: Error { }
