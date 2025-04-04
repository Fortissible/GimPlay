//
//  GenreEntity.swift
//  GimPlay
//
//  Created by Wildan on 25/03/25.
//

import Foundation
import RealmSwift

class GenreEntity: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String
    @Persisted var imageUrl: String?
    @Persisted var image: Data

    @Persisted(originProperty: "genres") var games: LinkingObjects<GameDetailEntity>

    convenience init(genre: GenreModel) {
        self.init()
        self.id = String(genre.id)
        self.name = genre.name
        self.image = genre.image?.jpegData(
            compressionQuality: 1
        ) ?? Data()
        self.imageUrl = genre.imageBackground
    }
}
