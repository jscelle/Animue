//
//  LocalError.swift
//  Animue
//
//  Created by Artem Raykh on 07.10.2023.
//

import Foundation

struct LocalError: LocalizedError {
    init(message: String) {
        self.errorDescription = message
    }
    
    var errorDescription: String?
}
