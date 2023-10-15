//
//  VideoDatabaseManager.swift
//  Animue
//
//  Created by Artem Raykh on 15.10.2023.
//

import Foundation
import Dependencies

struct VideoDatabaseManager {
    var load: @Sendable (String) async throws -> Double
    var save: @Sendable (String, Double) async throws -> ()
}

extension VideoDatabaseManager: DependencyKey {
    static var liveValue: VideoDatabaseManager {
        let controller = VideoSwiftDataController()
        
        return Self { id in
            try await controller.getTime(for: id)
        } save: { id, time in
            try await controller.save(id: id, time: time)
        }
    }
}

extension DependencyValues {
    var videoDatabaseManager: VideoDatabaseManager {
        get { self[VideoDatabaseManager.self] }
        set { self[VideoDatabaseManager.self] = newValue }
    }
}
