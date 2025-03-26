//
//  GenrePresenter.swift
//  GimPlay
//
//  Created by Wildan on 26/03/25.
//

import Foundation
import RxSwift

class GenrePresenter {
    private let useCase: IGameUseCase
    private let disposeBag = DisposeBag()
    
    //Reactive Vars
    let games = PublishSubject<[GameModel]>()
    let error = PublishSubject<String>()
    
    init(useCase: IGameUseCase) {
        self.useCase = useCase
    }
    
    func getGameList(query: String, genreId: String?, searchQuery: String?) {
        useCase.getGameList(query: query, genreId: genreId, searchQuery: searchQuery)
            .subscribe(
                onNext: { games in
                    self.games.onNext(games)
                },
                onError: { error in
                    self.error.onNext(error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }
}
