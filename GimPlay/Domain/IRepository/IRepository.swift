//
//  IRepository.swift
//  GimPlay
//
//  Created by Wildan on 07/03/25.
//

import Foundation

protocol IRepository {
    // MARK: - REMOTE REGION
    func getGamesRemote(query: String, genreId: String?, searchQuery: String?) async throws -> [GameModel]
    func getGenresRemote() async throws -> [GenreModel]
    func getGameDetailRemote(id: String) async throws -> GameDetailModel

    // MARK: - LOCAL REGION
    func getGamesLocal(filterByGenreId: Int?) async throws -> [GameModel]
    func getGameDetailLocal(id: Int) async throws -> GameDetailModel?
    func getGenresLocal() async throws -> [GenreModel]
    func isGameInLocal(id: Int) async -> Bool
    
    func addGameToFavourites(_ gameDetailModel: GameDetailModel) async throws
    
    func removeGameFromFavourites(id: Int) async throws
}
