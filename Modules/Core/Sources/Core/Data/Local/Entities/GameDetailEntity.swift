//
//  GameDetailEntity.swift
//  Core
//
//  Created by Zahra Nurul Izza on 11/04/25.
//

import Foundation
import RealmSwift

public class GameDetailEntity: Object {
    @Persisted(primaryKey: true) public var id: Int
    @Persisted public var name: String
    @Persisted public var playtime: Int
    @Persisted public var publisher: String
    @Persisted public var rating: Double
    @Persisted public var ratingTop: Int
    @Persisted public var released: String?
    @Persisted public var reviewsCount: Int
    @Persisted public var stores: String
    @Persisted public var desc: String
    @Persisted public var image: Data
    @Persisted public var imageUrl: String?
    @Persisted public var metacritic: Int?
    // Many-to-Many Relationship
    @Persisted public var genres = List<GenreEntity>()

    public convenience init(detail: GameDetailModel) {
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
