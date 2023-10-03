//
//  RequestBuilderTests.swift
//  AnimueTests
//
//  Created by Artem Raykh on 02.10.2023.
//

import Foundation
@testable import Animue
import XCTest

final class RequestBuilderTests: XCTestCase {
    
    var builder: RequestBuilder!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        builder = RequestBuilderImpl()
    }
    
    override func tearDownWithError() throws {
        builder = nil
        
        try super.tearDownWithError()
    }
    
    func testBuildRequestWithPlainTask() throws {
        let target = MockTarget()
        
        let request = try builder.build(target: target)
        
        XCTAssertEqual(request.httpMethod, target.method.rawValue)
        XCTAssertEqual(request.url, target.url.appendingPathComponent(target.path))
    }
    
    func testBuildRequestWithBodyTask() throws {
        let target = MockTargetWithBody()
        
        let request = try builder.build(target: target)
        
        XCTAssertEqual(request.httpMethod, target.method.rawValue)
        XCTAssertEqual(request.url, target.url.appendingPathComponent(target.path))
    }
    
    func testBuildRequestWithParametersTask() throws {
        let target = MockTargetWithParameters()
        
        let request = try builder.build(target: target)
        
        XCTAssertEqual(request.httpMethod, target.method.rawValue)
        XCTAssertEqual(request.url, target.url.appendingPathComponent(target.path))
    }
}

// Mock implementations for testing
struct MockTarget: Target {
    let url = URL(string: "https://example.com")!
    let path = "/test"
    let method = HTTPMethod.get
    let task = NetworkTask.plain
    let headers: [String: String]? = nil
    let authorizationHeaders: [String: String]? = nil
}

struct MockTargetWithBody: Target {
    let url = URL(string: "https://example.com")!
    let path = "/test"
    let method = HTTPMethod.post
    let task = NetworkTask.withBody("Request Body", encoder: JSONEncoder())
    let headers: [String: String]? = nil
    let authorizationHeaders: [String: String]? = nil
}

struct MockTargetWithParameters: Target {
    let url = URL(string: "https://example.com")!
    let path = "/test"
    let method = HTTPMethod.put
    let task = NetworkTask.withParameters(parameters: ["param": "value"], encoding: URLEncoding.default)
    let headers: [String: String]? = nil
    let authorizationHeaders: [String: String]? = nil
}

