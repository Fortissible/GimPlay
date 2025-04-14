//
//  GameDetailModel.swift
//  GimPlay
//
//  Created by Wildan on 09/03/25.
//

import Foundation

public class GameDetailModel: DownloadableImage {
    public let id: Int
    public let name, released, description: String
    public let rating: Double
    public let ratingTop: Int
    public let metacritic: Int
    public let playtime: Int
    public let reviewsCount: Int
    public let backgroundImage: String
    public let genres: [GenreModel]
    public let stores: [String]
    public let publisher: String
    public let isFavourite: Bool

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
