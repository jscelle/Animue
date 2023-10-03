//
//  JSONSerializer.swift
//  Animue
//
//  Created by Artem Raykh on 03.10.2023.
//

import Foundation
import Dependencies

protocol JSONSerializer {
    func serialize(data: Data) async throws -> String
}

final actor JSONSerializerImpl: JSONSerializer {
    func serialize(data: Data) async throws -> String {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
        
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        } else {
            throw NetworkError(type: .failedToSerialize, description: nil)
        }
    }
}

extension DependencyValues {
    
    private enum JSONSerializerKey: DependencyKey {
        static let liveValue: JSONSerializer = JSONSerializerImpl()
        
    }
    
    var jsonSerializer: JSONSerializer {
        get { self[JSONSerializerKey.self] }
        set { self[JSONSerializerKey.self] = newValue }
    }
}
