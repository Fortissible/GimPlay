//
//  Repository.swift
//  GimPlay
//
//  Created by Wildan on 07/03/25.
//

import Foundation
import RxSwift

class Repository : IRepository {
    private let remoteDataSource: RemoteDataSource // Inject remote
    private let localDataSource: LocalDataSource // Inject local
    
    init(remoteDS: RemoteDataSource, localDS: LocalDataSource) {
        self.remoteDataSource = remoteDS
        self.localDataSource = localDS
    }
}

extension Repository {
    // MARK: - REMOTE REGION
    func getGamesRemote(query: String, genreId: String?, searchQuery: String?) async throws -> [GameModel] {
        let result = try await remoteDataSource.getGamesFromApi(query: query, genreId: genreId, searchQuery: searchQuery)
        
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
    
    // MARK: - LOCAL REGION
    func getGamesLocal(query: String? = nil) -> Observable<[GameModel]> {
        return self.localDataSource.getAllFavouriteGames(query: query)
            .map {
                self.mapGameDetailEntitiesToGameModels(entity: $0)
            }
    }
    
    func isGameInLocal(id: Int) -> Observable<Bool> {
        return self.localDataSource.isGameInLocal(id: id)
    }
    
    
    func getGameDetailLocal(id: Int) -> Observable<GameDetailModel> {
        return self.localDataSource.getFavouriteGame(id)
            .map {
                self.mapGameDetailEntityToGameDetailModel(entity: $0)
            }
    }
    
    func getGenresLocal() -> Observable<[GenreModel]> {
        return self.localDataSource.getAllFavouriteGenres()
            .map {
                self.mapGenreEntitiesToGenreModels(entities: $0)
            }
    }
    
    func addGameToFavourites(
        _ gameDetailModel: GameDetailModel
    ) -> Observable<Bool> {
        return self.localDataSource.addFavouriteGame(gameDetailModel)
    }
    
    func removeGameFromFavourites(id: Int) -> Observable<Bool> {
        return self.localDataSource.removeFavouriteGame(id)
    }
}

// MARK: - MAPPING API RESPONSE MODEL TO DOMAIN MODEL UTILS
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
            publisher: res.publishers.first?.name ?? "No Name",
            isFavourite: false
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
                genres: genres,
                isFavourite: false
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
    
    fileprivate func mapGameDetailEntitiesToGameModels(
        entity gameDetailList: [GameDetailEntity]
    ) -> [GameModel] {
        return gameDetailList.map { gameDetail in
            var genres: [GenreModel] = mapGenreEntitiesToGenreModels(entities: Array(gameDetail.genres))
            
            return GameModel(
                id: gameDetail.id,
                name: gameDetail.name,
                released: gameDetail.released,
                rating: gameDetail.rating,
                ratingTop: gameDetail.ratingTop,
                metacritic: gameDetail.metacritic,
                backgroundImage: gameDetail.imageUrl,
                genres: genres
            )
        }
    }
    
    fileprivate func mapGameDetailEntityToGameDetailModel(
        entity gameDetail: GameDetailEntity
    ) -> GameDetailModel {
        
        var genres: [GenreModel] = mapGenreEntitiesToGenreModels(entities: Array(gameDetail.genres))
        
        return GameDetailModel(
            id: gameDetail.id,
            name: gameDetail.name,
            released: gameDetail.released,
            description: gameDetail.desc,
            rating: gameDetail.rating,
            ratingTop: gameDetail.ratingTop,
            metacritic: gameDetail.metacritic,
            backgroundImage: gameDetail.imageUrl,
            genres: genres,
            stores: gameDetail.stores.components(separatedBy: ", "),
            playtime: gameDetail.playtime,
            reviewsCount: gameDetail.reviewsCount,
            publisher: gameDetail.publisher
        )
    }
    
    fileprivate func mapGenreEntitiesToGenreModels(
        entities: [GenreEntity]
    ) -> [GenreModel] {
        return entities.map { entity in
            GenreModel(
                id: Int(entity.id) ?? 0,
                name: entity.name,
                imageBackground: entity.imageUrl
            )
        }
    }
}
