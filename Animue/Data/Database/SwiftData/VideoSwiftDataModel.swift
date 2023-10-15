//
//  VideoSwiftDataModel.swift
//  Animue
//
//  Created by Artem Raykh on 15.10.2023.
//

import Foundation
import SwiftData
import CoreMedia

@Model
final class VideoSwiftDataModel {
    @Attribute(.unique) let id: String
    let time: Double
    
    init(id: String, time: Double) {
        self.id = id
        self.time = time
    }
}
