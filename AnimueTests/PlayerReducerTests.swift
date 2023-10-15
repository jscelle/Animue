//
//  PlayerReducer.swift
//  AnimueTests
//
//  Created by Artem Raykh on 15.10.2023.
//

import Foundation
import XCTest
import ComposableArchitecture
import AVFoundation
@testable import Animue

@MainActor
final class PlayerReducerTests: XCTestCase {
    
    func testLoadWithSuccess() async {
        let videoURL = URL(string: "https://example.com/sample.mp4")!
        let videoId = "video123"
        let videoTime: Double = 30.0 // Replace with the expected time
        
        let store = TestStore(initialState: Player.State()) {
            Player()
                .dependency(\.videoDatabaseManager, .init(
                    load: { id in
                        videoTime
                    },
                    save: { _, _ in }
                )
            )
        }
        
        await store.send(.load(id: videoId, url: videoURL))
        
        await store.receive(/Player.Action.loadResponse(.success(videoTime)))
        
        await store.finish()
    }
    
    // Test the behavior when loading a video with an error
    func testLoadWithError() async {
        let videoURL = URL(string: "https://example.com/sample.mp4")!
        let videoId = "video123"
        let error = MockError()
        
        let store = TestStore(initialState: Player.State()) {
            Player()
                .dependency(\.videoDatabaseManager, .init(
                    load: { _ in throw error },
                    save: { _, _ in }
                )
            )
        }
        
        await store.send(.load(id: videoId, url: videoURL))
        
        await store.receive(/Player.Action.loadResponse(.failure(error)))
        
        await store.receive(/Player.Action.handle(error: error)) { state in
            state.error = AnimeError(error: error)
        }
        
        await store.finish()
    }
    
    // Test the behavior when saving a video
    func testSaveVideo() async {
        let videoId = "video123"
        
        let store = TestStore(initialState: Player.State()) {
            Player()
                .dependency(\.videoDatabaseManager, .init(
                    load: { _ in 0.0 },
                    save: { _, _ in
                        
                    }
                )
            )
        }
        
        await store.send(.save(id: videoId))
        
        await store.receive(/Player.Action.saveResponse(.success(())))
        
        // No state changes expected in this case, so no assertions
        await store.finish()
    }
    
    // Test the behavior when saving a video with an error
    func testSaveVideoWithError() async {
        let videoId = "video123"
        let error = MockError()
        
        let store = TestStore(initialState: Player.State()) {
            Player()
                .dependency(\.videoDatabaseManager, .init(
                    load: { _ in 0.0 },
                    save: { _, _ in throw error }
                )
            )
        }
        
        await store.send(.save(id: videoId))
        
        await store.receive(/Player.Action.saveResponse(.failure(error)))
        
        await store.receive(/Player.Action.handle(error: error)) { state in
            
            state.error = AnimeError(error: error)
        }
        
        await store.finish()
    }
}

fileprivate struct MockError: Error { }
