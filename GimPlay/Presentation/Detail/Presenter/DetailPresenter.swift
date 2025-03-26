//
//  DetailPresenter.swift
//  GimPlay
//
//  Created by Wildan on 26/03/25.
//

import Foundation
import RxSwift

class DetailPresenter {
    private let useCase: IGameUseCase
    private let disposeBag = DisposeBag()
    
    //Reactive Vars
    let gameDetail = PublishSubject<GameDetailModel>()
    let isFavourite = PublishSubject<Bool>()
    let error = PublishSubject<String>()
    
    init(useCase: IGameUseCase) {
        self.useCase = useCase
    }
    
    func getGameDetail(id: String) {
        useCase.getGameDetail(id: id)
            .subscribe(
                onNext: { (gameDetail, isFavourite) in
                    self.gameDetail.onNext(gameDetail)
                    self.isFavourite.onNext(isFavourite)
                },
                onError: { error in
                    self.error.onNext(error.localizedDescription)
                }
            ).disposed(by: disposeBag)
    }
}
