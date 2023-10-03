//
//  JSONSerializerTests.swift
//  AnimueTests
//
//  Created by Artem Raykh on 03.10.2023.
//

import Foundation
import XCTest
@testable import Animue

final class JSONSerializerTests: XCTestCase {
    
    var serializer: JSONSerializer!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        serializer = JSONSerializerImpl()
    }
    
    override func tearDownWithError() throws {
        serializer = nil
        
        try super.tearDownWithError()
    }
    
    func testSerializeValidJSONData() async throws {
        // Create a sample JSON object
        
        let key = "key"
        let value = "value"
        
        let jsonObject = [key: value]
        let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
        
        // Serialize the data
        let jsonString = try await serializer.serialize(data: jsonData)
        
        // Validate the serialized JSON string
        
        XCTAssertEqual(jsonString.contains(key) && jsonString.contains(value), true)
    }
    
    func testSerializeFailedSerialization() async throws {
        // Create data that cannot be serialized to JSON
        let invalidData = Data([0x01, 0x02, 0x03])
        
        // Attempt to serialize the invalid data
        do {
            _ = try await serializer.serialize(data: invalidData)
            XCTFail("Expected an error to be thrown for failed serialization")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}
