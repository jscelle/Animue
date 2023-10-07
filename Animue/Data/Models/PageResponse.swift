//
//  PageResponse.swift
//  Animue
//
//  Created by Artem Raykh on 07.10.2023.
//

import Foundation

struct PageResponse<T: Decodable>: Decodable {
    let currentPage: String?
    let hasNextPage: Bool?
    let results: [T]
}
