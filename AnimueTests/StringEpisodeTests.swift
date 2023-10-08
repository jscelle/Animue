//
//  StringEpisodeTests.swift
//  AnimueTests
//
//  Created by Artem Raykh on 08.10.2023.
//

import Foundation
import XCTest
@testable import Animue

final class StringEpisodeTests: XCTestCase {

    func testAddingEpisode() {
        var episodeTitle = "My favorite TV show"
        episodeTitle = episodeTitle.addingEpisode(number: 5)
        
        XCTAssertEqual(episodeTitle, "Episode 5 of My favorite TV show")
    }
    
    func testRemovingEpisode() {
        var episodeTitle = "My favorite TV show"
        episodeTitle = episodeTitle.addingEpisode(number: 5)
        
        episodeTitle = episodeTitle.removingEpisode()
        
        XCTAssertEqual(episodeTitle, "My favorite TV show")
    }
}
