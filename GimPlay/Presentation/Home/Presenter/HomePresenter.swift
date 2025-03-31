//
//  HomePresenter.swift
//  GimPlay
//
//  Created by Wildan on 26/03/25.
//

import Foundation
import RxSwift

class HomePresenter {
    private var page = 1
    private let useCase: IGameUseCase
    private let disposeBag = DisposeBag()
    var isLoading = false

    // Reactive Vars
    let games = PublishSubject<[GameModel]>()
    let genres = PublishSubject<[GenreModel]>()
    let error = PublishSubject<String>()

    init(useCase: IGameUseCase) {
        self.useCase = useCase
    }

    func getGames(query: String, genreId: String?, searchQuery: String?) {
        guard !isLoading else { return }

        isLoading = true

        useCase.getGameList(query: query, genreId: genreId, searchQuery: searchQuery, page: self.page)
            .subscribe(
                onNext: { games in
                    self.games.onNext(games)
                    self.page += 1
                    self.isLoading = false
                },
                onError: { error in
                    self.error.onNext(error.localizedDescription)
                    self.isLoading = false
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
