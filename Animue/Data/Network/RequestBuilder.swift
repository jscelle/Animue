//
//  RequestBuilder.swift
//  Animue
//
//  Created by Artem Raykh on 02.10.2023.
//

import Foundation
import Dependencies

protocol RequestBuilder {
    func build<T: Target>(target: T) throws -> URLRequest
}

final class RequestBuilderImpl: RequestBuilder {
    
    func build<T: Target>(target: T) throws -> URLRequest {
        var request = URLRequest(url: target.url.appendingPathComponent(target.path))
        request.httpMethod = target.method.rawValue
        
        handleHeaders(target.headers, request: &request)
        
        handleHeaders(target.authorizationHeaders, request: &request)
        
        try handleTask(target.task, request: &request)
        
        return request
    }
    
    // MARK: - Headers
    private func handleHeaders(_ headers: [String: String]?, request: inout URLRequest) {
        if let headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
    }
    
    // MARK: - Task. Query or body parameters
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

extension RequestBuilderImpl: DependencyKey {
    static var liveValue: RequestBuilder {
        RequestBuilderImpl()
    }
}

extension DependencyValues {
    var requestBuilder: RequestBuilder {
        get { self[RequestBuilderImpl.self] }
        set { self[RequestBuilderImpl.self] = newValue }
    }
}
