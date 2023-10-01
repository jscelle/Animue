//
//  Logger.swift
//  Animue
//
//  Created by Artem Raykh on 01.10.2023.
//

import Dependencies
import os

private enum LoggerKey: DependencyKey {
    static var liveValue = Logger()
}

extension DependencyValues {
    var logger: Logger {
        get { self[LoggerKey.self] }
        set { self[LoggerKey.self] = newValue }
    }
}
