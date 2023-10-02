//
//  NetworkManager.swift
//  Animue
//
//  Created by Artem Raykh on 01.10.2023.
//

import Foundation
import Dependencies

final class NetworkManagerImpl<T: Target> {
    
    @Dependency(\.requestBuilder) private var builder
    
    private let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func request<Object: Decodable>(_ target: T) async throws -> Object {
        // Create a URLRequest based on the Target
        
        let request = try builder.build(target: target)
        
        do {
            let (data, _) = try await session.data(for: request)
            
            // Decode the response data into the specified Codable object
            let decoder = JSONDecoder()
            let responseObject = try decoder.decode(Object.self, from: data)
            return responseObject
        } catch {
            throw error
        }
    }
}

