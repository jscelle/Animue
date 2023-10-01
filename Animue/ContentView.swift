//
//  ContentView.swift
//  animue
//
//  Created by Artem Raykh on 01.10.2023.
//

import SwiftUI

struct ContentView: View {
    
    private let networkManager = NetworkManagerImpl<AnimeTarget>()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            Task {
                do {
                    let object: PageResult = try await networkManager.request(
                        .fetchAnime(title: "demon", page: 2)
                    )
                    print(object)
                    
                    
                } catch {
                    print(error)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
