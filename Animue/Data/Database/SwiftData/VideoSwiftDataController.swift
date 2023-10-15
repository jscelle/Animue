//
//  VideoSwiftDataController.swift
//  Animue
//
//  Created by Artem Raykh on 15.10.2023.
//

import SwiftData
import Foundation
import Dependencies
import CoreMedia

final actor VideoSwiftDataController {
    let context: ModelContext
    
    @Dependency(\.logger) private var logger
    
    init() {
        do {
            let container = try ModelContainer(for: VideoSwiftDataModel.self)
            self.context = ModelContext(container)
        } catch {
            fatalError("Failed to create ModelContext")
        }
    }
    
    func getTime(for id: String) throws -> Double {
        logger.debug("Fetching time for id \(id) from SwiftData video database")
        
        let descriptor = FetchDescriptor<VideoSwiftDataModel>(
            predicate: #Predicate<VideoSwiftDataModel> { $0.id == id }
        )
        
        guard let time = try context.fetch(descriptor).map({ $0.time }).first else {
            throw LocalError(message: "Failed to fetch time for url in SwiftData Database")
        }
        
        return time
    }
    
    func save(id: String, time: Double) throws {
        let video = VideoSwiftDataModel(id: id, time: time)
        
        context.insert(video)
        
        logger.debug("Video \(String(describing: video)) inserted to video database, trying to save...")
        try context.save()
    }
}
