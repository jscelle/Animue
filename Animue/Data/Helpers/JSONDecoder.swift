//
//  JSONDecoder.swift
//  Animue
//
//  Created by Artem Raykh on 07.10.2023.
//

import Foundation
import Dependencies

extension DependencyValues {
    private enum JSONDecoderKey: DependencyKey {
        static var liveValue: JSONDecoder {
            let decoder = JSONDecoder()
            
            return decoder
        }
    }
    
    var jsonDecoder: JSONDecoder {
        get { self[JSONDecoderKey.self] }
        set { self[JSONDecoderKey.self] = newValue }
    }
}
