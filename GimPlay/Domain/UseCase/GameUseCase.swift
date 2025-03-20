//
//  GameUseCase.swift
//  GimPlay
//
//  Created by Wildan on 07/03/25.
//

import Foundation

class GameUseCase {
    private let repository: IRepository
    
    init(repository: IRepository) {
        self.repository = repository
    }
    // MARK: - REMOTE REGIONS
    func getGameList(query: String, genreId: String?, searchQuery: String?) async throws -> [GameModel] {
        return try await repository.getGamesRemote(query: query, genreId: genreId, searchQuery: searchQuery)
    }
    
    func getGenres() async throws -> [GenreModel] {
        return try await repository.getGenresRemote()
    }
    
    // MARK: - LOCAL REGIONS
    func getFavouriteGames(_ filterByGenreId: String? = nil) async throws -> [GameModel] {
        return try await repository.getGamesLocal(filterByGenreId: Int(filterByGenreId ?? "0"))
    }
    
    func getFavouriteGenres() async throws -> [GenreModel] {
        return try await repository.getGenresLocal()
    }
    
    func addFavouriteGame(_ game: GameDetailModel) async throws {
        try await repository.addGameToFavourites(game)
    }
    
    func removeFavouriteGame(_ id: Int) async throws {
        try await repository.removeGameFromFavourites(id: id)
    }
    
    // MARK: - OFFLINE FIRST REGION
    func getGameDetail(id: String) async throws -> (GameDetailModel, Bool) {
        let isFavourite: Bool = await repository.isGameInLocal(id: Int(id) ?? 0)
        if isFavourite {
            print("DATA GAME \(id) RETRIEVED FROM LOCAL")
            let localGameDetail: GameDetailModel = try await repository.getGameDetailLocal(id: Int(id) ?? 0)!
            return (localGameDetail, isFavourite)
        } else {
            print("DATA GAME \(id) RETRIEVED FROM REMOTE API")
            let remoteGameDetail: GameDetailModel = try await repository.getGameDetailRemote(id: id)
            return (remoteGameDetail, isFavourite)
        }
    }
}
