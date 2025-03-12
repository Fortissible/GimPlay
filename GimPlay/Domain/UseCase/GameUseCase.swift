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
    
    func getGameList(query: String, genreId: String?) async throws -> [GameModel] {
        return try await repository.getGamesRemote(query: query, genreId: genreId)
    }
    
    func getGenres() async throws -> [GenreModel] {
        return try await repository.getGenresRemote()
    }
    
    func getGameDetail(id: String) async throws -> GameDetailModel {
        return try await repository.getGameDetailRemote(id: id)
    }
}
