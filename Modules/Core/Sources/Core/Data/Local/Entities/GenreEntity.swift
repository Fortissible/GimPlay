//
//  GenreEntity.swift
//  Core
//
//  Created by Zahra Nurul Izza on 11/04/25.
//

import Foundation
import RealmSwift

public class GenreEntity: Object {
    @Persisted(primaryKey: true) public var id: String
    @Persisted public var name: String
    @Persisted public var imageUrl: String?
    @Persisted public var image: Data

    @Persisted(originProperty: "genres") var games: LinkingObjects<GameDetailEntity>

    convenience init(genre: GenreModel) {
        self.init()
        self.id = String(genre.id)
        self.name = genre.name
        self.image = genre.image ?? Data()
        self.imageUrl = genre.imageBackground
    }
}
