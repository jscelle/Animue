//
//  AnimeNetworkManager.swift
//  Animue
//
//  Created by Artem Raykh on 03.10.2023.
//

import Foundation
import Dependencies

struct SearchAnimeNetworkManager {
    var search: @Sendable (_ query: String, _ page: Int) async throws -> [Anime]
}

extension SearchAnimeNetworkManager: DependencyKey {
    static var liveValue: Self {
        let manager = LiveSearchAnimeNetworkManager()
        
        return Self { query, page in
            try await manager.search(query: query, page: page)
        }
    }
    
    static let testValue: Self = Self(
        search: unimplemented("Test value should be implemented after")
    )
    
    static var previewValue: Self {
        let mock = PreviewSearchAnimeNetworkManager()
        
        return Self { query, page in
            try await mock.search(query: query, page: page)
        }
    }
}

struct LiveSearchAnimeNetworkManager {
    
    @Dependency(\.animeProvider) private var provider
    
    func search(query: String, page: Int) async throws -> [Anime] {
        (try await provider.request(
            .fetchAnime(title: query, page: page)
        ) as PageResponse<Anime>)
        .results
    }
}

struct PreviewSearchAnimeNetworkManager {
    
    func search(query: String, page: Int) async throws -> [Anime] {
        (0...page * 10).map { number in
            Anime(
                id: "\(number)",
                title: Mock.animeTitles.randomElement()!,
                url: Mock.images.randomElement()!,
                image: Mock.images.randomElement()!,
                releaseDate: Mock.releaseDates.randomElement()!,
                subOrDub: .sub
            )
        }
    }
}

extension DependencyValues {
    var searchManager: SearchAnimeNetworkManager {
        get { self[SearchAnimeNetworkManager.self] }
        set { self[SearchAnimeNetworkManager.self] = newValue }
    }
}
