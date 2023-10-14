//
//  HorizontalListItem.swift
//  Animue
//
//  Created by Artem Raykh on 14.10.2023.
//

import SwiftUI

struct HorizontalItemView: View {
    let item: Anime
    
    var body: some View {
        VStack {
            CachedAsyncImage(url: item.image, urlCache: .shared) { image in
                
                GeometryReader { geometry in
                    image
                        .resizable()
                        .scaledToFill()
                        .clipped()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            } placeholder: {
                Color.gray
            }
            
            Text(item.title)
                .font(.system(.title2))
                .foregroundStyle(.white)
                .padding()
                .lineLimit(nil)
        }
        .frame(width: 150)
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
