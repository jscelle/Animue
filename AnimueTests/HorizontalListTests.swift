//
//  HorizontalListTests.swift
//  AnimueTests
//
//  Created by Artem Raykh on 08.10.2023.
//

import ComposableArchitecture
import XCTest
@testable import Animue

@MainActor
final class HorizontalListTests: XCTestCase {
    
    func testInitialLoadWithError() async {
        let error = MockError()
        
        let store = TestStore(initialState: HorizontalList.State()) {
            HorizontalList()
        } withDependencies: {
            
            $0.horizontalListManager.load = { _ in
                throw error
            }
        }
        
        await store.send(.initialLoad)
        
        await store.receive(
            /HorizontalList.Action.networkResponse(.failure(error))
        ) { state in
            state.error = AnimeError(error: error)
        }
        
        await store.finish()
    }
    
    
    func testInitialLoadWithSuccess() async {
        let items = mockItems
        
        let store = TestStore(initialState: HorizontalList.State()) {
            HorizontalList()
        } withDependencies: {
            
            $0.horizontalListManager.load = { _ in
                items
            }
        }
        
        await store.send(.initialLoad)
        
        await store.receive(
            /HorizontalList.Action.networkResponse(.success(items))
        ) { state in
            state.items = items // Expected items after receiving data
        }
        
        await store.finish()
    }
    
    // Test the behavior when a page is added and results in an error
    func testPageAddedWithError() async {
        let error = MockError()
        
        let store = TestStore(initialState: HorizontalList.State()) {
            HorizontalList()
        } withDependencies: {
            
            $0.horizontalListManager.load = { _ in
                throw error
            }
        }
        
        await store.send(.pageAdded) { state in
            state.page = 2
        }
        
        await store.receive(
            /HorizontalList.Action.networkResponse(.failure(error))
        ) { state in
            state.error = AnimeError(error: error)
        }
        
        await store.finish()
    }
    
    // Test the behavior when a page is added and succeeds
    func testPageAddedWithSuccess() async {
        let items = mockItems
        
        let store = TestStore(initialState: HorizontalList.State()) {
            HorizontalList()
        } withDependencies: {
            
            $0.horizontalListManager.load = { _ in
                items
            }
        }
        
        await store.send(.pageAdded) { state in
            state.page = 2
        }
        
        await store.receive(
            /HorizontalList.Action.networkResponse(.success(items))
        ) { state in
            state.items.append(contentsOf: items) // Expected items after receiving data
        }
        
        await store.finish()
    }
    
    func testSuccessNetworkResponse() async {
        let items = mockItems
        
        let store = TestStore(initialState: HorizontalList.State()) {
            HorizontalList()
        } withDependencies: {
            
            $0.horizontalListManager.load = { _ in
                items
            }
        }
        
        await store.send(.initialLoad)
        
        await store.receive(
            /HorizontalList.Action.networkResponse(.success(items))
        ) { state in
            state.items = items // Expected items after receiving data
        }
        
        await store.finish()
    }
}

fileprivate struct MockError: Error { }

fileprivate let mockItems = [
    HorizontalListItem(
        id: UUID().uuidString,
        title: Mock.animeTitles.randomElement()!,
        image: Mock.images.randomElement()!
    ),
    HorizontalListItem(
        id: UUID().uuidString,
        title: Mock.animeTitles.randomElement()!,
        image: Mock.images.randomElement()!
    ),
]
