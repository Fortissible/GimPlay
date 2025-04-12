//
//  GameDetailRes.swift
//  GameDetail
//
//  Created by Zahra Nurul Izza on 12/04/25.
//

import Foundation

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let gameDetail = try? JSONDecoder().decode(GameDetail.self, from: jsonData)

// MARK: - GameDetail
public struct GameDetailRes: Codable, Sendable {
    let id: Int
    let name, description: String
    let metacritic: Int?
    let released: String?
    let backgroundImage: String?
    let rating: Double
    let ratingTop: Int
    let playtime: Int // in hours
    let reviewsCount: Int
    let stores: [StoreDetail]
    let genres, tags, publishers: [NamedImageDetail]

    enum CodingKeys: String, CodingKey {
        case id, name
        case description = "description_raw"
        case metacritic
        case released
        case backgroundImage = "background_image"
        case rating
        case ratingTop = "rating_top"
        case playtime
        case reviewsCount = "reviews_count"
        case stores, genres, tags, publishers
    }
}

// MARK: - Developer
public struct NamedImageDetail: Codable, Sendable {
    let id: Int
    let name: String
    let imageBackground: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case imageBackground = "image_background"
    }
}

// MARK: - Store
public struct StoreDetail: Codable, Sendable {
    let id: Int
    let url: String?
    let store: NamedImageDetail
}
