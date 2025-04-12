//
//  GameDataMapper.swift
//  Game
//
//  Created by Zahra Nurul Izza on 11/04/25.
//
import Core
import Foundation

public struct GameDataMapper: DataMapper {
    public typealias Response = GamesRes
    public typealias Entities = [GameDetailEntity]
    public typealias Domain = [GameModel]

    public func transformResponseToDomain(response: Response) -> Domain {
        return response.results.map { game in
            let genres = game.genres.map { genre in
                return GenreModel(
                    id: genre.id,
                    name: genre.name,
                    imageBackground: genre.imageBackground ?? "https://placehold.co/600x400.png"
                )
            }
            return GameModel(
                id: game.id,
                name: game.name,
                released: game.released,
                rating: game.rating,
                ratingTop: game.ratingTop,
                metacritic: game.metacritic,
                backgroundImage: game.backgroundImage,
                genres: genres,
                isFavourite: false
            )
        }
    }

    public func transformEntitiesToDomain(entities: Entities) -> Domain {
        return entities.map { gameDetail in
            let genres: [GenreModel] = mapGenreEntitiesToGenreModels(entities: Array(gameDetail.genres))

            return GameModel(
                id: gameDetail.id,
                name: gameDetail.name,
                released: gameDetail.released,
                rating: gameDetail.rating,
                ratingTop: gameDetail.ratingTop,
                metacritic: gameDetail.metacritic,
                backgroundImage: gameDetail.imageUrl,
                genres: genres,
                isFavourite: true
            )
        }
    }

    fileprivate func mapGenreEntitiesToGenreModels(
        entities: [GenreEntity]
    ) -> [GenreModel] {
        return entities.map { entity in
            GenreModel(
                id: Int(entity.id) ?? 0,
                name: entity.name,
                imageBackground: entity.imageUrl ?? ""
            )
        }
    }
}
