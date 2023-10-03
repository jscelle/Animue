//
//  AnimeError.swift
//  Animue
//
//  Created by Artem Raykh on 03.10.2023.
//

import Foundation

struct AnimeError: LocalizedError {
    init(error: Error) {
        self.errorDescription = String(describing: error)
    }
    
    var errorDescription: String?
}

extension AnimeError: Equatable {
    
}
