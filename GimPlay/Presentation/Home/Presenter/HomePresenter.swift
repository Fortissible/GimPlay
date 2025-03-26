//
//  HomePresenter.swift
//  GimPlay
//
//  Created by Wildan on 26/03/25.
//

import Foundation
import RxSwift

class HomePresenter {
    private let useCase: IGameUseCase
    private let disposeBag = DisposeBag()
    
    //Reactive Vars
    let games = PublishSubject<[GameModel]>()
    let genres = PublishSubject<[GenreModel]>()
    let error = PublishSubject<String>()
    
    init(useCase: IGameUseCase) {
        self.useCase = useCase
    }
    
    func getGames(query: String, genreId: String?, searchQuery: String?) {
        useCase.getGameList(query: query, genreId: genreId, searchQuery: searchQuery)
            .subscribe(
                onNext: { games in
                    self.games.onNext(games)
                },
                onError: { error in
                    self.error.onNext(error.localizedDescription)
                }
            ).disposed(by: disposeBag)
    }
    
    func getGenres() {
        useCase.getGenres()
            .subscribe(
                onNext: { genres in
                    self.genres.onNext(genres)
                },
                onError: { error in
                    self.error.onNext(error.localizedDescription)
                }
            ).disposed(by: disposeBag)
    }
}
