//
//  IRepository.swift
//  GimPlay
//
//  Created by Wildan on 07/03/25.
//

import Foundation

protocol IRepository {
    func getGamesRemote(query: String, genreId: String?) async throws -> [GameModel]
    func getGenresRemote() async throws -> [GenreModel]
    func getGameDetailRemote(id: String) async throws -> GameDetailModel
}
