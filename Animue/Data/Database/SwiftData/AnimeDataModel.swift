//
//  AnimeDataModel.swift
//  Animue
//
//  Created by Artem Raykh on 08.10.2023.
//

import Foundation
import SwiftData

@Model
final class AnimeSwiftData {
    @Attribute(.unique) let id: String
    let title: String
    let image: URL
    
    init(id: String, title: String, image: URL) {
        self.id = id
        self.title = title
        self.image = image
    }
}
