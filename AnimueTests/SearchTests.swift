//
//  SearchTests.swift
//  AnimueTests
//
//  Created by Artem Raykh on 07.10.2023.
//

import XCTest
import ComposableArchitecture
@testable import Animue

@MainActor
final class SearchReducerTests: XCTestCase {

    // Test the behavior when a page adding fails
    func testPageAddedWithError() async {
        let error = MockError()
        
        let store = TestStore(initialState: SearchReducer.State()) {
            SearchReducer()
                .dependency(\.mainQueue, .main)
                .dependency(\.searchManager, .init(search: { _, _ in throw error }))
        }
        
        await store.send(.pageAdded) { state in
            state.page = 2
        }
        
        await store.receive(
            /SearchReducer.Action.networkResponse(.failure(error))
        ) { state in
            state.error = AnimeError(error: error)
        }
        
        await store.finish()
    }
    
    // Test the behavior when a page adding succeeds
    func testPageAddedWithSuccess() async {
        let anime = mockDtoAnime
        
        let store = TestStore(initialState: SearchReducer.State()) {
            SearchReducer()
                .dependency(\.mainQueue, .main)
                .dependency(\.searchManager, .init(search: { _, _ in anime }))
        }
        
        await store.send(.pageAdded) { state in
            state.page = 2
        }
        
        await store.receive(
            /SearchReducer.Action.networkResponse(.success(anime))
        ) { state in
            state.results.append(contentsOf: anime) // Expected results after receiving data
        }
        
        await store.finish()
    }
    
    // Test the behavior when a query is changed and results in an error
    func testQueryChangedWithError() async {
        let error = MockError()
        
        let store = TestStore(initialState: SearchReducer.State()) {
            SearchReducer()
                .dependency(\.mainQueue, .main)
                .dependency(\.searchManager, .init(search: { _, _ in throw error }))
        }
        
        await store.send(.queryChanged("New Query")) { state in
            state.searchQuery = "New Query"
        }
        
        await store.receive(
            /SearchReducer.Action.networkResponse(.failure(error))
        ) { state in
            state.error = AnimeError(error: error)
        }
        
        await store.finish()
    }
    
    // Test the behavior when a query change succeeds
    func testQueryChangedWithSuccess() async {
        let anime = mockDtoAnime
        
        let store = TestStore(initialState: SearchReducer.State()) {
            SearchReducer()
                .dependency(\.mainQueue, .main)
                .dependency(\.searchManager, .init(search: { _, _ in anime }))
        }
        
        await store.send(.queryChanged("New Query")) { state in
            state.searchQuery = "New Query" // Expected search query after sending the action
        }
        
        await store.receive(
            /SearchReducer.Action.networkResponse(.success(anime))
        ) { state in
            state.results = anime
        }
        
        await store.finish()
        
    }
    
    // Test clearing the results if query is empty
    func testNetworkCancelationIfEmptyQuery() async {
        
        let anime = [AnimeSearchDTO(
            id: UUID().uuidString,
            title: Mock.animeTitles.randomElement()!,
            url: Mock.images.randomElement()!,
            image: Mock.images.randomElement()!,
            releaseDate: "2000",
            subOrDub: .dub
        )]
        
        let store = TestStore(initialState: SearchReducer.State()) {
            SearchReducer()
                .dependency(\.mainQueue, .main)
                .dependency(\.searchManager, .init(search: { _, _ in anime }))
        }
        
        // Set the query
        await store.send(.queryChanged("New Query")) { state in
            state.searchQuery = "New Query"
        }
        
        // Get the mock network response
        await store.receive(
            /SearchReducer.Action.networkResponse(.success([]))
        ) { state in
            state.results = anime
        }
        
        // Empty the query, empty the results
        await store.send(.queryChanged("")) { state in
            state.searchQuery = ""
            state.results = []
        }
        
        await store.finish()
    }
}

fileprivate struct MockError: Error { }

fileprivate let mockDtoAnime = [
    AnimeSearchDTO(
        id: UUID().uuidString,
        title: Mock.animeTitles.randomElement()!,
        url: Mock.images.randomElement()!,
        image: Mock.images.randomElement()!,
        releaseDate: "2021",
        subOrDub: .dub
    ),
    AnimeSearchDTO(
        id: UUID().uuidString,
        title: Mock.animeTitles.randomElement()!,
        url: Mock.images.randomElement()!,
        image: Mock.images.randomElement()!,
        releaseDate: "2022",
        subOrDub: .dub
    ),
    AnimeSearchDTO(
        id: UUID().uuidString,
        title: Mock.animeTitles.randomElement()!,
        url: Mock.images.randomElement()!,
        image: Mock.images.randomElement()!,
        releaseDate: "2023",
        subOrDub: .dub
    )
]

fileprivate let mockAnime = [
    Anime(
        id: UUID().uuidString,
        title: Mock.animeTitles.randomElement()!,
        image: Mock.images.randomElement()!
    )
]
