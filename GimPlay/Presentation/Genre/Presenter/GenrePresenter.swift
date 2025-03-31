//
//  GenrePresenter.swift
//  GimPlay
//
//  Created by Wildan on 26/03/25.
//

import Foundation
import RxSwift

class GenrePresenter {
    private var page = 1
    private var isLoading = false
    private let useCase: IGameUseCase
    private let disposeBag = DisposeBag()

    // Reactive Vars
    let games = PublishSubject<[GameModel]>()
    let error = PublishSubject<String>()

    init(useCase: IGameUseCase) {
        self.useCase = useCase
    }

    func getGameList(query: String, genreId: String?, searchQuery: String?) {
        guard !isLoading else { return }

        isLoading = true

        useCase.getGameList(query: query, genreId: genreId, searchQuery: searchQuery, page: page)
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
            )
            .disposed(by: disposeBag)
    }
}
