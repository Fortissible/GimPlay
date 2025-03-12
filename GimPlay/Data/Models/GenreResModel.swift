//
//  GenreResModel.swift
//  GimPlay
//
//  Created by Wildan on 09/03/25.
//

import Foundation

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let genres = try? JSONDecoder().decode(Genres.self, from: jsonData)

// MARK: - Genres
struct GenreRes: Codable {
    let count: Int
    let results: [Genres]
}

// MARK: - Result
struct Genres: Codable {
    let id: Int
    let name, slug: String
    let gamesCount: Int
    let imageBackground: String
    let games: [GamesGenre]

    enum CodingKeys: String, CodingKey {
        case id, name, slug
        case gamesCount = "games_count"
        case imageBackground = "image_background"
        case games
    }
}

// MARK: - Game
struct GamesGenre: Codable {
    let id: Int
    let slug, name: String
    let added: Int
}
