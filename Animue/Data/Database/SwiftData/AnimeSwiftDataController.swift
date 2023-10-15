//
//  SwiftDataController.swift
//  Animue
//
//  Created by Artem Raykh on 08.10.2023.
//

import Dependencies
import SwiftData
import Foundation

final actor AnimeSwiftDataController {
    
    let context: ModelContext
    
    @Dependency(\.logger) private var logger
    
    init() {
        do {
            let container = try ModelContainer(for: AnimeSwiftData.self)
            self.context = ModelContext(container)
        } catch {
            fatalError("Failed to create ModelContext")
        }
    }
    
    func save(anime: Anime) throws {
        logger.debug("Saving \(String(describing: anime)) to anime SwiftData database")
        
        context.insert(anime.toSwiftData())
        
        try context.save()
    }
    
    func fetch(id: String) throws -> Anime {
        logger.debug("Fetching anime with ID \(id) from SwiftData anime database")
        
        let descriptor = FetchDescriptor<AnimeSwiftData>(
            predicate: #Predicate<AnimeSwiftData> { $0.id == id }
        )
        
        guard let anime = try context.fetch(descriptor).map({ $0.convert() }).first else {
            throw LocalError(message: "Failed to locate anime with this id in SwiftData Database")
        }
        
        return anime
    }
    
    func fetchAll() throws -> [Anime] {
        logger.debug("Fetching all of anime from SwiftData anime database")
        
        let descriptor = FetchDescriptor<AnimeSwiftData>()
        
        return try context.fetch(descriptor).map { $0.convert() }
    }
    
    func delete(id: String) throws {
        logger.debug("Deleting anime with ID \(id) from anime database")
        
        let descriptor = FetchDescriptor<AnimeSwiftData>(
            predicate: #Predicate<AnimeSwiftData> { $0.id == id }
        )
        
        for result in try context.fetch(descriptor) {
            context.delete(result)
        }
        
        try context.save()
    }
    
    func deleteAll() throws {
        logger.debug("Deleting all anime from anime database")
        
        let descriptor = FetchDescriptor<AnimeSwiftData>()
        
        for result in try context.fetch(descriptor) {
            context.delete(result)
        }
        
        try context.save()
    }
}
