//
//  GenreDataMapper.swift
//  Genre
//
//  Created by Zahra Nurul Izza on 12/04/25.
//
import Core

public struct GenreDataMapper: DataMapper {
    public typealias Response = GenreRes
    public typealias Entities = [GenreEntity]
    public typealias Domain = [GenreModel]

    public func transformResponseToDomain(response: Response) -> Domain {
        return genreRes.results.map { genre in
            return GenreModel(
                id: genre.id,
                name: genre.name,
                imageBackground: genre.imageBackground
            )
        }
    }

    public func transformEntitiesToDomain(entities: Entities) -> Domain {
        return entities.map { entity in
            GenreModel(
                id: Int(entity.id) ?? 0,
                name: entity.name,
                imageBackground: entity.imageUrl ?? ""
            )
        }
    }
}
