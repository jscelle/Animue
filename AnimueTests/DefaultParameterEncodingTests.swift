//
//  DefaultParameterEncodingTests.swift
//  AnimueTests
//
//  Created by Artem Raykh on 01.10.2023.
//

import Foundation
import XCTest
@testable import Animue

final class DefaultParameterEncodingTests: XCTestCase {
    
    var encoder: Encoding!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        encoder = URLEncoding.default
    }
    
    override func tearDownWithError() throws {
        encoder = nil
        try super.tearDownWithError()
    }
    
    func testEncodingParametersInGETRequest() throws {
        let url = URL(string: "https://example.com")!
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        
        let parameters: [String: Any] = [
            "age": 30
        ]
        
        let response = try encoder.encode(base: request, parameters: parameters)
            
        // Verify the encoded URL
        XCTAssertEqual(response.url?.absoluteString, "https://example.com?age=30")
    }
    
    func testEncodingParametersInPOSTRequest() throws {
        let url = URL(string: "https://example.com")!
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue // Use POST method
        
        let parameters: [String: Any] = [
            "username": "user123",
            "password": "password456"
        ]
        
        let response = try encoder.encode(base: request, parameters: parameters)
        
        // Verify the encoded HTTP body
        XCTAssertEqual(response.httpBody?.count, "username=user123&password=password456".data(using: .utf8)?.count)
    }
    
    func testEncodingEmptyParameters() throws {
        let url = URL(string: "https://example.com")!
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        
        let parameters: [String: Any] = [:] // Empty parameters
        
        let response = try encoder.encode(base: request, parameters: parameters)
            
        // Verify that the URL remains unchanged
        XCTAssertEqual(response.url?.absoluteString, "https://example.com")
    }
    
    func testEmptyURL() throws {
        let url = URL(string: "https://example.com")!
        var request = URLRequest(url: url)
        request.url = nil
        request.httpMethod = HTTPMethod.get.rawValue
        
        let parameters: [String: Any] = [:] // Empty parameters
        
        do {
            _ = try encoder.encode(base: request, parameters: parameters)
            XCTFail("Expected an error to be thrown")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}
