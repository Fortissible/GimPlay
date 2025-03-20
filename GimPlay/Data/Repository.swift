//
//  Repository.swift
//  GimPlay
//
//  Created by Wildan on 07/03/25.
//

import Foundation

class Repository : IRepository {
    private let remoteDataSource: RemoteDataSource // Inject remote
    private let localDataSource: LocalDataSource // Inject local
    
    init(remoteDS: RemoteDataSource, localDS: LocalDataSource) {
        self.remoteDataSource = remoteDS
        self.localDataSource = localDS
    }
    
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
    func getGamesLocal(filterByGenreId: Int? = nil) async throws -> [GameModel] {
        var gameList: [GameModel] = []
        await localDataSource.getAllFavouriteGames(filterByGenreId: filterByGenreId) { games in
            gameList = games
        }
        return gameList
    }
    
    func isGameInLocal(id: Int) async -> Bool {
        return await localDataSource.isGameInLocal(id: id)
    }
    
    
    func getGameDetailLocal(id: Int) async throws -> GameDetailModel? {
        var gameDetail: GameDetailModel?
        await localDataSource.getFavouriteGame(id) { game in
            gameDetail = game
        }
        return gameDetail
    }
    
    func getGenresLocal() async throws -> [GenreModel] {
        var genreList: [GenreModel] = []
        await localDataSource.getAllFavouriteGenres { genres in
            genreList = genres
        }
        return genreList
    }
    
    func addGameToFavourites(
        _ gameDetailModel: GameDetailModel
    ) async throws {
        await withCheckedContinuation { continuation in
            localDataSource.addFavouriteGame(gameDetailModel) {
                print("DATA GAME \(gameDetailModel.id) SUCCESSFULY SAVED TO LOCAL")
                continuation.resume()
            }
        }
    }
    
    func removeGameFromFavourites(id: Int) async throws {
        await withCheckedContinuation { continuation in
            Task {
                await localDataSource.removeFavouriteGame(id) {
                    continuation.resume()
                }
                await localDataSource.deleteUnusedGenres()
                print("DATA GAME \(id) SUCCESSFULY REMOVED FROM LOCAL")
            }
        }
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
}
