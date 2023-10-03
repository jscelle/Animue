//
//  AnimeNetworkManager.swift
//  Animue
//
//  Created by Artem Raykh on 03.10.2023.
//

import Foundation
import Dependencies

protocol AnimeNetworkManager {
    @Sendable func search(query: String, page: Int) async throws -> [Anime]
}

struct AnimeNetworkManagerImpl: AnimeNetworkManager {
    
    private let networkProvider = NetworkProvider<AnimeTarget>()
    
    func search(query: String, page: Int) async throws -> [Anime] {
        (try await networkProvider.request(
            .fetchAnime(title: query, page: page)
        ) as PageResult)
        .results
    }
}

struct MockAnimeNetworkManagerImpl: AnimeNetworkManager {
    func search(query: String, page: Int) async throws -> [Anime] {
        return []
    }
}

extension DependencyValues {
    
    private enum AnimeNetworkDependencyKey: DependencyKey {
        static let liveValue: AnimeNetworkManager = AnimeNetworkManagerImpl()
        
        static let testValue: AnimeNetworkManager = MockAnimeNetworkManagerImpl()
    }
    
    var networkManager: AnimeNetworkManager {
        get { self[AnimeNetworkDependencyKey.self] }
        set { self[AnimeNetworkDependencyKey.self] = newValue }
    }
}
