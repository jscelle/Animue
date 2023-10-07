//
//  PageResponse.swift
//  Animue
//
//  Created by Artem Raykh on 02.10.2023.
//

import Foundation

struct Anime: Decodable {
    let id: String
    let title: String
    let url: URL
    let image: URL
    let releaseDate: String
    let subOrDub: SubOrDub
}

enum SubOrDub: Decodable {
    case sub, dub
}

extension Anime: Equatable { }
