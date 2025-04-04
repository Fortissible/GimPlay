//
//  Game.swift
//  GimPlay
//
//  Created by Wildan on 07/03/25.
//

import Foundation

// MARK: - Game
struct GamesRes: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [Result]

    enum CodingKeys: String, CodingKey {
        case count, next, previous, results
    }
}

// MARK: - Result
struct Result: Codable {
    let id: Int
    let name: String
    let released: String?
    let rating: Double
    let ratingTop: Int
    let metacritic: Int?
    let backgroundImage: String?
    let genres: [Genre]

    enum CodingKeys: String, CodingKey {
        case id, name, released
        case rating
        case ratingTop = "rating_top"
        case metacritic
        case backgroundImage = "background_image"
        case genres
    }
}

// MARK: - Genre
struct Genre: Codable {
    let id: Int
    let name: String
    let imageBackground: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case imageBackground = "image_background"
    }
}
