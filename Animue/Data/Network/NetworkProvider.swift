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
    
    @Dependency (\.jsonDecoder) private var jsonDecoder
    
    func request<Object: Decodable>(_ target: T) async throws -> Object {
        
        let request = try builder.build(target: target)
        
        logger.debug("The request is \(String(describing: request))")
        
        let (data, _) = try await session.data(for: request)

        let dataDescription = try await jsonSerializer.serialize(data: data)
        
        logger.debug("The response for request \(String(describing: request)) is \(dataDescription)")
        
        let responseObject = try jsonDecoder.decode(Object.self, from: data)
        return responseObject
    }
}

extension DependencyValues {
    private enum ProviderKey: DependencyKey {
        static var liveValue: NetworkProvider<AnimeTarget> {
            NetworkProvider<AnimeTarget>()
        }
    }
    
    var animeProvider: NetworkProvider<AnimeTarget> {
        get { self[ProviderKey.self] }
    }
}

