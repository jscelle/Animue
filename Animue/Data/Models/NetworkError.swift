//
//  NetworkError.swift
//  Animue
//
//  Created by Artem Raykh on 01.10.2023.
//

import Foundation

struct NetworkError: LocalizedError {
    init(type: Type, description: String?) {
        self.errorDescription = "Network error, type: \(String(describing: type)), description: \(description ?? "")"
    }
    
    var errorDescription: String?
    
    enum `Type` {
        case missingURL
        case failedToSerialize
    }
}

