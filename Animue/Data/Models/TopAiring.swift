//
//  TopAiring.swift
//  Animue
//
//  Created by Artem Raykh on 07.10.2023.
//

import Foundation

struct TopAiring: Decodable {
    let id: String
    let title: String
    let url: URL
    let image: URL
    let genres: [String]
}

extension TopAiring: Equatable { }
