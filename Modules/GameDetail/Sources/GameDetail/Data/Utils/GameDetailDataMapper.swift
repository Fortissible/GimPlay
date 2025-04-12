//
//  GameDetailDataMapper.swift
//  GameDetail
//
//  Created by Zahra Nurul Izza on 12/04/25.
//
import Core

public struct GameDetailDataMapper: DataMapper {
    public typealias Response = GameDetailRes
    public typealias Entities = GameDetailEntity
    public typealias Domain = GameDetailModel

    public func transformResponseToDomain(response: Response) -> Domain {
        return GameDetailModel(
            id: response.id,
            name: response.name,
            released: response.released ?? "No Release Data",
            description: response.description,
            rating: response.rating,
            ratingTop: response.ratingTop,
            metacritic: response.metacritic ?? 0,
            backgroundImage: response.backgroundImage ?? "https://placehold.co/600x400.png",
            genres: response.genres.map { genre in
                return GenreModel(
                    id: genre.id,
                    name: genre.name,
                    imageBackground: genre.imageBackground ?? "https://placehold.co/600x400.png"
                )
            },
            stores: response.stores.map { store in
                return store.store.name
            },
            playtime: response.playtime,
            reviewsCount: response.reviewsCount,
            publisher: response.publishers.first?.name ?? "No Name",
            isFavourite: false
        )
    }

    public func transformEntitiesToDomain(entities: Entities) -> Domain {
        let genres: [GenreModel] = mapGenreEntitiesToGenreModels(entities: Array(entities.genres))

        return GameDetailModel(
            id: entities.id,
            name: entities.name,
            released: entities.released ?? "",
            description: entities.desc,
            rating: entities.rating,
            ratingTop: entities.ratingTop,
            metacritic: entities.metacritic ?? 0,
            backgroundImage: entities.imageUrl ?? "",
            genres: genres,
            stores: entities.stores.components(separatedBy: ", "),
            playtime: entities.playtime,
            reviewsCount: entities.reviewsCount,
            publisher: entities.publisher,
            isFavourite: true
        )
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
