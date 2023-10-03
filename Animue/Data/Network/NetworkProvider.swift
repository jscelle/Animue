//
//  NetworkProvider.swift
//  Animue
//
//  Created by Artem Raykh on 01.10.2023.
//

import Foundation
import Dependencies

final actor NetworkProvider<T: Target> {
    
    @Dependency(\.requestBuilder) private var builder
    
    @Dependency(\.urlSession) private var session
        
    @Dependency(\.logger) private var logger
    
    @Dependency(\.jsonSerializer) private var jsonSerializer
    
    func request<Object: Decodable>(_ target: T) async throws -> Object {
        
        let request = try builder.build(target: target)
        
        logger.debug("The request is \(String(describing: request))")
        
        let (data, _) = try await session.data(for: request)
        
        let dataDescription = try await jsonSerializer.serialize(data: data)
        
        logger.debug("The response for request \(String(describing: request)) is \(dataDescription)")
        
        // Decode the response data into the specified Codable object
        let decoder = JSONDecoder()
        let responseObject = try decoder.decode(Object.self, from: data)
        return responseObject
    }
}

