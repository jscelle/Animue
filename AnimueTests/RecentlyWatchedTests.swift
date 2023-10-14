//
//  RecentlyWatchedTests.swift
//  AnimueTests
//
//  Created by Artem Raykh on 13.10.2023.
//

import ComposableArchitecture
import XCTest
@testable import Animue

@MainActor
final class RecentlyWatchedStoreTests: XCTestCase {
    
    // Test the behavior when loading recently watched anime with success
    func testLoadWithSuccess() async {
        
        let mockAnime = Anime(
            id: UUID().uuidString,
            title: Mock.animeTitles.randomElement()!,
            image: Mock.images.randomElement()!
        )
        
        let store = TestStore(initialState: RecentlyVisited.State()) {
            RecentlyVisited()
                .dependency(\.animeDatabaseManager, .init(
                    save: { _ in },
                    fetchAll: { [mockAnime] },
                    delete: { _ in },
                    deleteAll: { }
                )
            )
        }
        
        await store.send(.load)
        
        await store.receive(/RecentlyVisited.Action.dataResponse(.success([mockAnime]))) { state in
            state.recentlyWatched = [mockAnime]
        }
        
        await store.finish()
    }
    
    // Test the behavior when loading recently watched anime with an error
    func testLoadWithError() async {
        let error = MockError()
        
        let store = TestStore(initialState: RecentlyVisited.State()) {
            RecentlyVisited()
                .dependency(\.animeDatabaseManager, .init(
                    save: { _ in },
                    fetchAll: { throw error },
                    delete: { _ in },
                    deleteAll: { }
                )
            )
        }
        
        await store.send(.load)
        
        await store.receive(/RecentlyVisited.Action.dataResponse(.failure(error))) { state in
            state.error = AnimeError(error: error)
        }
        
        await store.finish()
    }
    
    // Test the behavior when deleting a recently watched anime with success
    func testDeleteWithSuccess() async {
        
        let mockAnime = Anime(
            id: UUID().uuidString,
            title: Mock.animeTitles.randomElement()!,
            image: Mock.images.randomElement()!
        )
        
        let store = TestStore(initialState: RecentlyVisited.State()) {
            RecentlyVisited()
                .dependency(\.animeDatabaseManager, .init(
                    save: { _ in },
                    fetchAll: { [mockAnime] },
                    delete: { _ in },
                    deleteAll: { }
                )
            )
        }
        
        // Initial load, so we can actually delete presented item
        await store.send(.load)
        
        await store.receive(/RecentlyVisited.Action.dataResponse(.success([mockAnime]))) { state in
            state.recentlyWatched = [mockAnime]
        }
        
        // Delete item
        await store.send(.delete(mockAnime.id))
        
        await store.receive(/RecentlyVisited.Action.emptyResponse(.success(())))
        
        await store.receive(/RecentlyVisited.Action.load)
    
        // No state changes occured, becase it returns same value every time
        await store.receive(/RecentlyVisited.Action.dataResponse(.success([mockAnime])))
        
        await store.finish()
    }
    
    // Test the behavior when deleting a recently watched anime with an error
    func testDeleteWithError() async {
        
        let error = MockError()
        
        let mockAnime = Anime(
            id: UUID().uuidString,
            title: Mock.animeTitles.randomElement()!,
            image: Mock.images.randomElement()!
        )
        
        let store = TestStore(initialState: RecentlyVisited.State()) {
            RecentlyVisited()
                .dependency(\.animeDatabaseManager, .init(
                    save: { _ in },
                    fetchAll: { [mockAnime] },
                    delete: { _ in throw error },
                    deleteAll: { }
                )
            )
        }
        
        // Initial load, so we can actually delete presented item
        await store.send(.load)
        
        await store.receive(/RecentlyVisited.Action.dataResponse(.success([mockAnime]))) { state in
            state.recentlyWatched = [mockAnime]
        }
        
        // Delete the item
        await store.send(.delete(mockAnime.id))
        
        await store.receive(/RecentlyVisited.Action.emptyResponse(.failure(error))) { state in
            state.error = AnimeError(error: error)
        }
        
        // No events should occur after error
        await store.finish()
    }
    
    func testDeleteNoPresented() async {
        
        let store = TestStore(initialState: RecentlyVisited.State()) {
            RecentlyVisited()
                .dependency(\.animeDatabaseManager, .init(
                    save: { _ in },
                    fetchAll: { [] },
                    delete: { _ in },
                    deleteAll: { }
                )
            )
        }
        
        // Initial load, so we can actually delete presented item
        await store.send(.load)
        
        await store.receive(/RecentlyVisited.Action.dataResponse(.success([])))
        
        // Delete the item, which is not presented
        await store.send(.delete(""))
        
        // No unhandled changes should happen
        await store.finish()
    }
    
    // Test the behavior when deleting all recently watched anime with success
    func testDeleteAllWithSuccess() async {
        
        let store = TestStore(initialState: RecentlyVisited.State()) {
            RecentlyVisited()
                .dependency(\.animeDatabaseManager, .init(
                    save: { _ in },
                    fetchAll: { [] },
                    delete: { _ in },
                    deleteAll: { }
                )
            )
        }
        
        await store.send(.deleteAll)
        
        await store.receive(/RecentlyVisited.Action.emptyResponse(.success(())))

        await store.receive(/RecentlyVisited.Action.load)
        
        // No state changes occured, becase it returns same value every time
        // Actualy it happens because of copy-on-write mechanism
        await store.receive(/RecentlyVisited.Action.dataResponse(.success([])))
        
        await store.finish()
    }
    
    // Test the behavior when deleting all recently watched anime with an error
    func testDeleteAllWithError() async {
        
        let error = MockError()
        
        let store = TestStore(initialState: RecentlyVisited.State()) {
            RecentlyVisited()
                .dependency(\.animeDatabaseManager, .init(
                    save: { _ in },
                    fetchAll: { [] },
                    delete: { _ in },
                    deleteAll: { throw error }
                )
            )
        }
        
        await store.send(.deleteAll)
        
        await store.receive(/RecentlyVisited.Action.emptyResponse(.failure(error))) { state in
            state.error = AnimeError(error: error)
        }
        
        // No changes should occure after error
        await store.finish()
    }
}

fileprivate struct MockError: Error { }
