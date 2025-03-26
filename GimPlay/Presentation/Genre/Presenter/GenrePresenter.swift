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
}
