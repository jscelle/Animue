//
//  AnimeTarget.swift
//  Animue
//
//  Created by Artem Raykh on 02.10.2023.
//

import Foundation

struct AnimeTarget: Target {
    var url: URL
    
    var path: String
    
    var method: HTTPMethod
    
    var task: NetworkTask
    
    var headers: [String : String]?
    
    var authorizationHeaders: [String : String]?
}

extension AnimeTarget {
    static func fetchAnime(title: String, page: Int) -> AnimeTarget {
        AnimeTarget(
            url: Config.baseURL,
            path: "anime/gogoanime/\(title)",
            method: .get,
            task: .withParameters(
                parameters: [
                    "page": page
                ],
                encoding: URLEncoding.default
            )
        )
    }
    
    static func topAiring(page: Int) -> AnimeTarget {
        AnimeTarget(
            url: Config.baseURL,
            path: "anime/gogoanime/top-airing",
            method: .get,
            task: .withParameters(
                parameters: [
                    "page": page
                ],
                encoding: URLEncoding.default
            )
        )
    }
    
    static func recentEpisodes(page: Int) -> AnimeTarget {
        AnimeTarget(
            url: Config.baseURL,
            path: "anime/gogoanime/recent-episodes",
            method: .get,
            task: .withParameters(
                parameters: [
                    "page": page
                ],
                encoding: URLEncoding.default
            )
        )
    }
}
