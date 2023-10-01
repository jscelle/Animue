//
//  HTTPMethods.swift
//  Animue
//
//  Created by Artem Raykh on 02.10.2023.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
    case head = "HEAD"
    case options = "OPTIONS"
    case connect = "CONNECT"
    case trace = "TRACE"
}
