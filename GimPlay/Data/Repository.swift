//
//  Repository.swift
//  GimPlay
//
//  Created by Wildan on 07/03/25.
//

import Foundation

class Repository : IRepository {
    private let remoteDataSource: RemoteDataSource // Inject
    
    init(remoteDS: RemoteDataSource) {
        self.remoteDataSource = remoteDS
    }
    
    func getGamesRemote(query: String, genreId: String?) async throws -> [GameModel] {
        let result = try await remoteDataSource.getGamesFromApi(query: query, genreId: genreId)
        
        return mapGameResToGameModel(res: result)
    }
    
    func getGenresRemote() async throws -> [GenreModel] {
        let result = try await remoteDataSource.getGenresFromApi()
        
        return mapGenreResToGenreModel(res: result)
    }
    
    func getGameDetailRemote(id: String) async throws -> GameDetailModel {
        let result = try await remoteDataSource.getGameDetailFromApi(id: id)
        
        return mapDetailResToDetailModel(res: result)
    }
}

extension Repository {
    fileprivate func mapDetailResToDetailModel(res: GameDetailRes) -> GameDetailModel {
        return GameDetailModel(
            id: res.id,
            name: res.name,
            released: res.released ?? "No Release Data",
            description: res.description,
            rating: res.rating,
            ratingTop: res.ratingTop,
            metacritic: res.metacritic ?? 0,
            backgroundImage: res.backgroundImage ?? "https://placehold.co/600x400.png",
            genres: res.genres.map { genre in
                return GenreModel(
                    id: genre.id,
                    name: genre.name,
                    imageBackground: genre.imageBackground ?? "https://placehold.co/600x400.png"
                )
            },
            stores: res.stores.map { store in
                return store.store.name
            },
            playtime: res.playtime,
            reviewsCount: res.reviewsCount,
            publisher: res.publishers.first?.name ?? "No Name"
        )
    }
    fileprivate func mapGameResToGameModel(
        res gameResponse: GamesRes
    ) -> [GameModel] {
        return gameResponse.results.map { game in
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
                genres: genres
            )
        }
    }
    
    fileprivate func mapGenreResToGenreModel(
        res genreRes: GenreRes
    ) -> [GenreModel] {
        return genreRes.results.map { genre in
            return GenreModel(
                id: genre.id,
                name: genre.name,
                imageBackground: genre.imageBackground
            )
        }
    }
}
