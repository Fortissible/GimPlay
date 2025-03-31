//
//  GameUseCase.swift
//  GimPlay
//
//  Created by Wildan on 07/03/25.
//

import Foundation
import RxSwift

protocol IGameUseCase {
    func getGameList(query: String, genreId: String?, searchQuery: String?) -> Observable<[GameModel]>
    func getGenres() -> Observable<[GenreModel]>

    func getFavouriteGames(_ query: String?) -> Observable<[GameModel]>
    func getFavouriteGenres() -> Observable<[GenreModel]>
    func addFavouriteGame(_ game: GameDetailModel) -> Observable<Bool>
    func removeFavouriteGame(_ id: Int) -> Observable<Bool>
    func deleteUnusedGenres() -> Observable<Bool>
    func getGameDetail(id: String) -> Observable<(GameDetailModel, Bool)>
    func isGameInLocal(id: Int) -> Observable<Bool>
}

class GameUseCase: IGameUseCase {
    private let repository: IRepository

    init(repository: IRepository) {
        self.repository = repository
    }
    // MARK: - REMOTE REGIONS
    func getGameList(query: String, genreId: String?, searchQuery: String?) -> Observable<[GameModel]> {
        return repository.getGamesRemote(query: query, genreId: genreId, searchQuery: searchQuery)
    }

    func getGenres() -> Observable<[GenreModel]> {
        return repository.getGenresRemote()
    }

    // MARK: - LOCAL REGIONS
    func getFavouriteGames(_ query: String? = nil) -> Observable<[GameModel]> {
        return repository.getGamesLocal(query: query)
    }

    func getFavouriteGenres() -> Observable<[GenreModel]> {
        return repository.getGenresLocal()
    }

    func addFavouriteGame(_ game: GameDetailModel) -> Observable<Bool> {
        return repository.addGameToFavourites(game)
    }

    func removeFavouriteGame(_ id: Int) -> Observable<Bool> {
        return repository.removeGameFromFavourites(id: id)
    }

    func deleteUnusedGenres() -> Observable<Bool> {
        return repository.deleteUnusedGenres()
    }

    func isGameInLocal(id: Int) -> Observable<Bool> {
        return repository.isGameInLocal(id: id)
    }

    // MARK: - OFFLINE FIRST REGION
    func getGameDetail(id: String) -> Observable<(GameDetailModel, Bool)> {
        return repository.isGameInLocal(id: Int(id) ?? 0)
            .flatMap { isFavourite in
                if isFavourite {
                    return self.repository.getGameDetailLocal(id: Int(id) ?? 0)
                        .map { localGameDetail in
                            return (localGameDetail, isFavourite)
                        }
                } else {
                    return self.repository.getGameDetailRemote(id: id)
                        .map { remoteGameDetail in
                            return (remoteGameDetail, isFavourite)
                        }
                }
            }
    }
}
