//
//  AnimeData + Convert .swift
//  Animue
//
//  Created by Artem Raykh on 08.10.2023.
//

import Foundation

extension AnimeCoreData {
    func convert() -> Anime? {
        guard
            let id = id,
            let title = title,
            let image = image,
            let url = URL(string: image)
        else {
            return nil
        }
        
        return Anime(id: id, title: title, image: url)
    }
}

extension AnimeSwiftData {
    func convert() -> Anime {
        Anime(id: id, title: title, image: image)
    }
}

extension Anime {
    func toSwiftData() -> AnimeSwiftData {
        AnimeSwiftData(id: id, title: title, image: image)
    }
}
