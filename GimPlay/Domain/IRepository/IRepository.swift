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
    func getGamesRemote(query: String, genreId: String?, searchQuery: String?) -> Observable<[GameModel]>
    func getGameDetailRemote(id: String) -> Observable<GameDetailModel>
    
    func getGenresRemote() -> Observable<[GenreModel]>

    // MARK: - LOCAL REGION
    func getGamesLocal(query: String?) -> Observable<[GameModel]>
    func getGameDetailLocal(id: Int) -> Observable<GameDetailModel>
    func isGameInLocal(id: Int) -> Observable<Bool>
    
    func addGameToFavourites(_ gameDetailModel: GameDetailModel) -> Observable<Bool>
    func removeGameFromFavourites(id: Int) -> Observable<Bool>
    
    func getGenresLocal() -> Observable<[GenreModel]>
    func deleteUnusedGenres() -> Observable<Bool>
}
