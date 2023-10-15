//
//  AnimeDatabaseManager.swift
//  Animue
//
//  Created by Artem Raykh on 08.10.2023.
//

import Dependencies

struct AnimeDatabaseManager {
    var save: @Sendable (Anime) async throws -> ()
    var fetchAll: @Sendable () async throws -> [Anime]
    var delete: @Sendable (String) async throws -> ()
    var deleteAll: @Sendable () async throws -> ()
}

extension AnimeDatabaseManager: DependencyKey {
    static var liveValue: AnimeDatabaseManager {
        
        guard #available(iOS 17, *) else {
            return .coreData
        }
        
        return .swiftData
    }
    
    static var previewValue: AnimeDatabaseManager {
        Self(
            save: unimplemented("Saving is not implemented in preview"),
            fetchAll: {
                (0...10).map { number in
                    Anime(
                        id: "\(number)",
                        title: Mock.animeTitles.randomElement()!,
                        image: Mock.images.randomElement()!
                    )
                }
            },
            delete: unimplemented("Delete is not implemented in preview"),
            deleteAll: unimplemented("Delete all is not implemented in preview")
        )
    }
    
    static var testValue: AnimeDatabaseManager {
        Self(
            save: unimplemented("Saving is not implemented in test"),
            fetchAll: unimplemented("Fetch All is not implemented in test"),
            delete: unimplemented("Delete is not implemented in test"),
            deleteAll: unimplemented("Delete all is not implemented in test")
        )
    }
    
    static var coreData: AnimeDatabaseManager {
        let controller = AnimeCoredataController()
        
        let context = controller.container.newBackgroundContext()
        
        return Self(
            save: { anime in
                try await controller.save(anime: anime, context: context)
            },
            fetchAll: {
                try await controller.fetchAll(context: context)
            },
            delete: { id in
                try await controller.delete(id: id, context: context)
            },
            deleteAll: {
                try await controller.deleteAll(context: context)
            }
        )
    }
    
    static var swiftData: AnimeDatabaseManager {
        let controller = AnimeSwiftDataController()
        
        return Self(
            save: { anime in
                try await controller.save(anime: anime)
            },
            fetchAll: {
                try await controller.fetchAll()
            },
            delete: { id in
                try await controller.delete(id: id)
            },
            deleteAll: {
                try await controller.deleteAll()
            }
        )
    }
}

extension DependencyValues {
    var animeDatabaseManager: AnimeDatabaseManager {
        get { self[AnimeDatabaseManager.self] }
        set { self[AnimeDatabaseManager.self] = newValue }
    }
}
