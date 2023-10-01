//
//  PageResponse.swift
//  Animue
//
//  Created by Artem Raykh on 02.10.2023.
//

import Foundation

struct PageResult: Decodable {
    let currentPage: String?
    let hasNextPage: Bool?
    let results: [Anime]
}

struct Anime: Decodable {
    let id: String
    let title: String
    let url: String
    let image: String
    let releaseDate: String
    let subOrDub: String
}
