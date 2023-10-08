//
//  String + Episodes.swift
//  Animue
//
//  Created by Artem Raykh on 08.10.2023.
//

import Foundation

extension String {
    func addingEpisode(number: Int) -> String {
        return "Episode \(number) of \(self)"
    }
    
    func removingEpisode() -> String {
        var updatedString = self
        if let range = updatedString.range(of: "Episode \\d+ of ", options: .regularExpression) {
            updatedString = updatedString.replacingCharacters(in: range, with: "")
        }
        return updatedString
    }
}
