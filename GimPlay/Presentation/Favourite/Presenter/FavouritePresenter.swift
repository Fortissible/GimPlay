//
//  FavouritePresenter.swift
//  GimPlay
//
//  Created by Wildan on 26/03/25.
//

import Foundation
import RxSwift

class FavouritePresenter {
    private let useCase: IGameUseCase
    private let disposeBag = DisposeBag()
    
    //Reactive Vars
    let games = PublishSubject<[GameModel]>()
    let genres = PublishSubject<[GenreModel]>()
    let error = PublishSubject<String>()
    
    init(useCase: IGameUseCase) {
        self.useCase = useCase
    }
    
    func getFavouriteGames(_ query: String? = nil) {
        useCase.getFavouriteGames(query)
            .subscribe(
                onNext: { games in
                    self.games.onNext(games)
                },
                onError: { error in
                    self.error.onNext(
                        error.localizedDescription
                    )
                }
            ).disposed(by: disposeBag)
    }
    
    func getFavouriteGenres() {
        useCase.getFavouriteGenres()
            .subscribe(
                onNext: { genres in
                    self.genres.onNext(genres)
                },
                onError: { error in
                    self.error.onNext(
                        error.localizedDescription
                    )
                }
            ).disposed(by: disposeBag)
    }
    
    func removeFavouriteGame(_ gameId: Int) {
        useCase.removeFavouriteGame(gameId)
            .subscribe(
                onNext: { isSuccess in
                    print("Success removing game \(gameId) from favourite")
                },
                onError: { error in
                    print("Fail to remove game \(gameId) from favourite")
                }
            ).disposed(by: disposeBag)
        
        useCase.deleteUnusedGenres()
            .subscribe(
                onNext: { res in
                },
                onError: {error in
                }
            )
            .disposed(by: disposeBag)
    }
}
