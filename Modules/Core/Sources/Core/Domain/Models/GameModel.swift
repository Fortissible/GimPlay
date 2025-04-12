//
//  GameModel.swift
//  GimPlay
//
//  Created by Wildan on 07/03/25.
//

import Foundation

public class GameModel: DownloadableImage {
    let id: Int
    let name: String
    let released: String?
    let rating: Double
    let ratingTop: Int
    let metacritic: Int?
    let backgroundImage: String?
    let genres: [GenreModel]
    let isFavourite: Bool

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
