//
//  Encoding.swift
//  Animue
//
//  Created by Artem Raykh on 01.10.2023.
//

import Foundation

protocol Encoding {
    func encode(base: URLRequest, parameters: [String: Any]) throws -> URLRequest
    func query(from parameters: [String: Any]) -> String
}

extension Encoding {
    var `default`: Encoding {
        URLEncoding()
    }
}

final class URLEncoding: Encoding {
    
    static let `default`: Encoding = URLEncoding()
    
    func encode(base: URLRequest, parameters: [String: Any]) throws -> URLRequest {
        var request = base
        
        guard let url = request.url else {
            throw NetworkError(type: .missingURL, description: nil)
        }
        
        if let method = request.httpMethod, method == HTTPMethod.get.rawValue {
            if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
                let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(from: parameters)
                urlComponents.percentEncodedQuery = percentEncodedQuery
                request.url = urlComponents.url
            }
        } else {
            request.httpBody = Data(query(from: parameters).utf8)
        }
        
        return request
    }
    
    func query(from parameters: [String: Any]) -> String {
        var components: [(String, String)] = []
        
        for (key, value) in parameters {
            let keyString = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let valueString = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            components.append((keyString, valueString))
        }
        
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
}

