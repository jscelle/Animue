//
//  Target.swift
//  Animue
//
//  Created by Artem Raykh on 01.10.2023.
//

import Foundation

enum NetworkTask {
    case plain
    case withBody(Encodable, encoder: JSONEncoder)
    case withParameters(parameters: [String: Any], encoding: Encoding)
}

protocol Target {
    var url: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var task: NetworkTask { get }
    var headers: [String : String]? { get }
    var authorizationHeaders: [String: String]? { get }
}
