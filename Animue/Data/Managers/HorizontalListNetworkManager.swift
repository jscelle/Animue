//
//  HorizontalListNetworkManager.swift
//  Animue
//
//  Created by Artem Raykh on 07.10.2023.
//

import Foundation
import Dependencies

struct HorizontalListNetworkManager {
    var load: @Sendable (_ page: Int) async throws -> [HorizontalListItem]
}

extension HorizontalListNetworkManager: DependencyKey {
    static var liveValue: Self = .mock
    
    static let testValue: HorizontalListNetworkManager = Self(
        load: unimplemented("Test value should be implemented after")
    )
    
    static let previewValue: Self = .mock
    
    static var mock: Self {
        let mock = MockListNetworkManager()
        
        return Self { page in
            try await mock.load(page: page)
        }
    }
    
    static var topAiring: Self {
        let manager = TopAiringListNetworkManager()
        
        return Self { page in
            try await manager.load(page: page)
        }
    }
    
    static var recentEpisodes: Self {
        let manager = RecentEpisodesListNetworkManager()
        
        return Self { page in
            try await manager.load(page: page)
        }
    }
}

extension DependencyValues {
    var horizontalListManager: HorizontalListNetworkManager {
        get { self[HorizontalListNetworkManager.self] }
        set { self[HorizontalListNetworkManager.self] = newValue }
    }
}

struct TopAiringListNetworkManager {
    @Dependency(\.animeProvider) private var provider

    func load(page: Int) async throws -> [HorizontalListItem] {
        (try await provider.request(.topAiring(page: page)) as PageResponse<TopAiring>)
            .results
            .map { anime in
                HorizontalListItem(
                    id: anime.id,
                    title: anime.title,
                    image: anime.image
                )
            }
    }
}

struct RecentEpisodesListNetworkManager {
    @Dependency(\.animeProvider) private var provider
    
    func load(page: Int) async throws -> [HorizontalListItem] {
        (try await provider.request(.recentEpisodes(page: page)) as PageResponse<Episode>)
            .results
            .map { episode in
                HorizontalListItem(
                    id: episode.id,
                    title: "Episode \(episode.episodeNumber) of \(episode.title)",
                    image: episode.image
                )
            }
    }
}

struct MockListNetworkManager {
    func load(page: Int) async throws -> [HorizontalListItem] {
        (0...page * 10).map { number in
            HorizontalListItem(
                id: "\(number)",
                title: Mock.animeTitles.randomElement()!,
                image: Mock.images.randomElement()!
            )
        }
    }
}