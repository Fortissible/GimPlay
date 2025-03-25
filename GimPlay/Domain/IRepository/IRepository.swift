//
//  IRepository.swift
//  GimPlay
//
//  Created by Wildan on 07/03/25.
//

import Foundation
import RxSwift

protocol IRepository {
    // MARK: - REMOTE REGION
    func getGamesRemote(query: String, genreId: String?, searchQuery: String?) async throws -> [GameModel]
    func getGameDetailRemote(id: String) async throws -> GameDetailModel
    
    func getGenresRemote() async throws -> [GenreModel]

    // MARK: - LOCAL REGION
    func getGamesLocal(query: String?) -> Observable<[GameModel]>
    func getGameDetailLocal(id: Int) -> Observable<GameDetailModel>
    func isGameInLocal(id: Int) -> Observable<Bool>
    
    func addGameToFavourites(_ gameDetailModel: GameDetailModel) -> Observable<Bool>
    func removeGameFromFavourites(id: Int) -> Observable<Bool>
    
    func getGenresLocal() -> Observable<[GenreModel]>
}
