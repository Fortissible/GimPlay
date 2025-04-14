//
//  GameModel.swift
//  GimPlay
//
//  Created by Wildan on 07/03/25.
//

import Foundation

public class GameModel: DownloadableImage {
    public let id: Int
    public let name: String
    public let released: String?
    public let rating: Double
    public let ratingTop: Int
    public let metacritic: Int?
    public let backgroundImage: String?
    public let genres: [GenreModel]
    public let isFavourite: Bool

    public init(
        id: Int,
        name: String,
        released: String?,
        rating: Double,
        ratingTop: Int,
        metacritic: Int?,
        backgroundImage: String?,
        genres: [GenreModel],
        isFavourite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.released = released
        self.rating = rating
        self.ratingTop = ratingTop
        self.metacritic = metacritic
        self.backgroundImage = backgroundImage
        self.genres = genres
        self.isFavourite = isFavourite

        super.init()
    }
}
