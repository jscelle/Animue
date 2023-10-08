//
//  AnimeDatabaseController.swift
//  Animue
//
//  Created by Artem Raykh on 08.10.2023.
//

import CoreData
import Dependencies

final actor AnimeCoredataController {
    
    let container: NSPersistentContainer
    
    @Dependency(\.logger) private var logger
    
    init() {
        
        container = NSPersistentContainer(name: "AnimeModel")
        
        container.loadPersistentStores { desc, error in
            
            @Dependency(\.logger) var logger
            
            if let error {
                logger.error("Error occured while loading container! \(String(describing: error))")
            }
        }
    }
    
    func save(anime: Anime, context: NSManagedObjectContext) throws {
        logger.debug("Saving \(String(describing: anime)) to anime database")
        
        let data = AnimeCoreData(context: context)
        data.id = anime.id
        data.title = anime.title
        data.image = anime.image.absoluteString
        
        try context.save()
    }
    
    func fetch(id: String, context: NSManagedObjectContext) throws -> Anime {
        logger.debug("Deleting anime with ID \(id) from anime database")
        
        // Fetch the anime data to be deleted
        let fetchRequest: NSFetchRequest<AnimeCoreData> = AnimeCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        guard 
            let anime = try context.fetch(fetchRequest).first,
            let anime = anime.convert()
        else {
            throw LocalError(message: "Failed to fetch id \(id) from anime database")
        }
        
        return anime
    }
    
    func fetchAll(context: NSManagedObjectContext) throws -> [Anime] {
        logger.debug("Fetching all anime from anime database")
        
        // Fetch all anime data and delete them
        let fetchRequest: NSFetchRequest<AnimeCoreData> = AnimeCoreData.fetchRequest()
        
        return try context.fetch(fetchRequest).compactMap { anime in
            
            guard let anime = anime.convert() else {
                return nil
            }
            
            return anime
        }
    }
    
    func delete(id: String, context: NSManagedObjectContext) throws {
        logger.debug("Deleting anime with ID \(id) from anime database")
        
        // Fetch the anime data to be deleted
        let fetchRequest: NSFetchRequest<AnimeCoreData> = AnimeCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        let results = try context.fetch(fetchRequest).compactMap { $0 }
        
        for result in results {
            context.delete(result)
        }
        
        try context.save()
    }
    
    func deleteAll(context: NSManagedObjectContext) throws {
        logger.debug("Deleting all anime from anime database")
        
        // Fetch all anime data and delete them
        let fetchRequest: NSFetchRequest<AnimeCoreData> = AnimeCoreData.fetchRequest()
        
        for animeData in try context.fetch(fetchRequest) {
            context.delete(animeData)
        }
        
        try context.save()
    }
}
