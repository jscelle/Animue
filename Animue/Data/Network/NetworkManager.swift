//
//  NetworkManager.swift
//  Animue
//
//  Created by Artem Raykh on 01.10.2023.
//

import Foundation

final class NetworkManagerImpl<T: Target> {
    
    private let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func request<Object: Decodable>(_ target: T) async throws -> Object {
        // Create a URLRequest based on the Target
        var request = URLRequest(url: target.url.appendingPathComponent(target.path))
        request.httpMethod = target.method.rawValue
        
        handleHeaders(target.headers, request: &request)
        
        handleHeaders(target.authorizationHeaders, request: &request)
        
        try handleTask(target.task, request: &request)
        
        do {
            let (data, _) = try await session.data(for: request)
            
            // Decode the response data into the specified Codable object
            let decoder = JSONDecoder()
            let responseObject = try decoder.decode(Object.self, from: data)
            return responseObject
        } catch {
            throw error
        }
    }
    
    // MARK: - Headers
    private func handleHeaders(_ headers: [String: String]?, request: inout URLRequest) {
        if let headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
    }
    
    // MARK: Task. Query or body parameters
    private func handleTask(_ task: NetworkTask, request: inout URLRequest) throws {
        switch task {
        case .plain:
            break
        case .withBody(let body, let encoder):
            request.httpBody = try encoder.encode(body)
        case .withParameters(let parameters, let encoding):
            request = try encoding.encode(base: request, parameters: parameters)
        }
    }
}

