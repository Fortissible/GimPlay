//
//  GameDetailEntity.swift
//  Core
//
//  Created by Zahra Nurul Izza on 11/04/25.
//

import Foundation
import RealmSwift

public class GameDetailEntity: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var name: String
    @Persisted var playtime: Int
    @Persisted var publisher: String
    @Persisted var rating: Double
    @Persisted var ratingTop: Int
    @Persisted var released: String?
    @Persisted var reviewsCount: Int
    @Persisted var stores: String
    @Persisted var desc: String
    @Persisted var image: Data
    @Persisted var imageUrl: String?
    @Persisted var metacritic: Int?
    // Many-to-Many Relationship
    @Persisted var genres = List<GenreEntity>()

    convenience init(detail: GameDetailModel) {
        self.init()

        self.id = detail.id
        self.name = detail.name
        self.playtime = detail.playtime
        self.publisher = detail.publisher
        self.rating = detail.rating
        self.ratingTop = detail.ratingTop
        self.released = detail.released
        self.reviewsCount = detail.reviewsCount
        self.stores = detail.stores.joined(separator: ", ")
        self.desc = detail.description
        self.image = detail.image ?? Data()
        self.imageUrl = detail.backgroundImage
        self.metacritic = detail.metacritic

        self.genres.append(objectsIn: detail.genres.map { genre in
            GenreEntity(genre: genre)
        })
    }
}
