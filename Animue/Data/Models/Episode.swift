//
//  Episode.swift
//  Animue
//
//  Created by Artem Raykh on 07.10.2023.
//

import Foundation

struct Episode: Decodable {
    let id: String
    let episodeId: String
    let episodeNumber: Int
    let title: String
    let image: URL
    let url: URL
}
