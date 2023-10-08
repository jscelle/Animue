//
//  animueApp.swift
//  animue
//
//  Created by Artem Raykh on 01.10.2023.
//

import SwiftUI
import ComposableArchitecture

@main
struct animueApp: App {
    var body: some Scene {
        WindowGroup {
            MainSearchView(
                store: Store(
                    initialState: MainSearchReducer.State(),
                    reducer: {
                        MainSearchReducer()
                    }
                )
            )
            .preferredColorScheme(.dark)
        }
    }
}
