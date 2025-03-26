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
}
