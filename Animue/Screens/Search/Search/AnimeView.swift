//
//  AnimeView.swift
//  Animue
//
//  Created by Artem Raykh on 03.10.2023.
//

import SwiftUI

struct AnimeView: View {
    
    let anime: AnimeSearchDTO
    
    var body: some View {
        VStack {
            CachedAsyncImage(url: anime.image, urlCache: .shared) { image in
                image
                    .resizable()
                    .scaledToFill()
                
            } placeholder: {
                Color.gray
            }
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 25,
                    style: .continuous
                )
            )
            
            Text(anime.title)
        }
    }
}
