//
//  SearchQueue.swift
//  Animue
//
//  Created by Artem Raykh on 03.10.2023.
//

import Foundation
import Dependencies
import Combine

extension DependencyValues {
    private enum SearchQueueKey: DependencyKey {
        static let liveValue = AnySchedulerOf<DispatchQueue>
            .init(DispatchQueue(label: "SearchQueue", attributes: .concurrent))
        
        static let testValue = AnySchedulerOf<DispatchQueue>
            .unimplemented(#"@DInjected(\.searchQueue) is unimplemented"#)
    }
    
    var searchQueue: AnySchedulerOf<DispatchQueue> {
        get { self[SearchQueueKey.self] }
        set { self[SearchQueueKey.self] = newValue }
    }
}
