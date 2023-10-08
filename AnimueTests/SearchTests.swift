//
//  SearchTests.swift
//  AnimueTests
//
//  Created by Artem Raykh on 07.10.2023.
//

import XCTest
import ComposableArchitecture
@testable import Animue // Replace with your app's module name

@MainActor
final class SearchReducerTests: XCTestCase {

    // Test the behavior when a page adding fails
    func testPageAddedWithError() async {
        let error = MockError()
        
        let store = TestStore(initialState: SearchReducer.State()) {
            SearchReducer()
        } withDependencies: {
            
            $0.mainQueue = .main
            
            $0.searchManager.search = { _, _  in throw error }
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
        } withDependencies: {
            
            $0.mainQueue = .main
            
            $0.searchManager.search = { _, _ in
                anime
            }
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
        } withDependencies: {
            
            $0.mainQueue = .main
            
            $0.searchManager.search = { _, _  in throw error }
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
        } withDependencies: {
            
            $0.mainQueue = .main
            
            $0.searchManager.search = { _, _ in
                anime
            }
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
        
        let store = TestStore(initialState: SearchReducer.State()) {
            SearchReducer()
        } withDependencies: {
            
            $0.mainQueue = .main
            
            $0.searchManager.search = { _, _  in
                try await Task.never()
            }
        }
        
        // Set the query
        await store.send(.queryChanged("New Query")) { state in
            state.searchQuery = "New Query"
        }
        
        // Empty the query
        await store.send(.queryChanged("")) { state in
            state.searchQuery = ""
            state.results = []
        }
        
        await store.finish()
    }
    
    func testRecentsLoading() async {
        let anime = mockAnime
        
        let store = TestStore(initialState: SearchReducer.State()) {
            SearchReducer()
        } withDependencies: {
            
            $0.animeDatabaseManager.fetchAll = {
                anime
            }
        }
        
        await store.send(.loadRecent)
        
        await store.receive(
            /SearchReducer.Action.databaseResponse(.success(anime))
        ) { state in
            state.recent = anime
        }
        
        await store.finish()
    }

    func testRecentsDeletion() async {
        
        let mockAnime = mockAnime
        
        let animeIdToDelete = mockAnime.first!.id
        
        var withoutDeleted = mockAnime
        withoutDeleted.removeAll { $0.id == animeIdToDelete }
        
        let store = TestStore(initialState: SearchReducer.State()) {
            SearchReducer()
        } withDependencies: {
            $0.animeDatabaseManager.fetchAll = {
                mockAnime
            }
            
            $0.animeDatabaseManager.delete = {
                _ in
            }
        }
        
        await store.send(.loadRecent)
        
        await store.receive(
            /SearchReducer.Action.databaseResponse(.success(mockAnime))
        ) { state in
            state.recent = mockAnime // Expected recent anime after receiving data
        }
        
        await store.send(.deleteRecent(animeIdToDelete))
        
        await store.receive(/SearchReducer.Action.databaseResponse(.success([]))) { state in
            state.recent = withoutDeleted
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
