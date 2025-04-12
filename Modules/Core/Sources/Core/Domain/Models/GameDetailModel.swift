//
//  GameDetailModel.swift
//  GimPlay
//
//  Created by Wildan on 09/03/25.
//

import Foundation

public class GameDetailModel: DownloadableImage {
    let id: Int
    let name, released, description: String
    let rating: Double
    let ratingTop: Int
    let metacritic: Int
    let playtime: Int
    let reviewsCount: Int
    let backgroundImage: String
    let genres: [GenreModel]
    let stores: [String]
    let publisher: String
    let isFavourite: Bool

    public init(
        id: Int,
        name: String,
        released: String,
        description: String,
        rating: Double,
        ratingTop: Int,
        metacritic: Int,
        backgroundImage: String,
        genres: [GenreModel],
        stores: [String],
        playtime: Int,
        reviewsCount: Int,
        publisher: String,
        isFavourite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.released = released
        self.description = description
        self.rating = rating
        self.ratingTop = ratingTop
        self.metacritic = metacritic
        self.backgroundImage = backgroundImage
        self.genres = genres
        self.playtime = playtime
        self.stores = stores
        self.reviewsCount = reviewsCount
        self.publisher = publisher
        self.isFavourite = isFavourite
    }
}
