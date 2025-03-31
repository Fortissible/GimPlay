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

    // Reactive Vars
    let gameDetail = PublishSubject<GameDetailModel>()
    let isFavourite = PublishSubject<Bool>()
    let error = PublishSubject<String>()

    init(useCase: IGameUseCase) {
        self.useCase = useCase
    }

    func isGameInLocalStorage(_ id: Int?) {
        useCase.isGameInLocal(id: id ?? 0)
            .subscribe(
                onNext: { isFavourite in
                    self.isFavourite.onNext(isFavourite)
                }
            )
            .disposed(by: disposeBag)
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

    func addFavouriteGame(_ gameDetail: GameDetailModel) {
        useCase.addFavouriteGame(gameDetail)
            .subscribe(
                onNext: { res in
                    self.isFavourite.onNext(res)
                },
                onError: { error in
                    self.error.onNext(error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }

    func removeFavouriteGame(_ gameDetailId: Int) {
        useCase.removeFavouriteGame(gameDetailId)
            .subscribe(
                onNext: { res in
                    self.isFavourite.onNext(!res)
                },
                onError: { error in
                    self.error.onNext(error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)

        useCase.deleteUnusedGenres()
            .subscribe(
                onNext: { _ in
                },
                onError: { _ in
                }
            )
            .disposed(by: disposeBag)
    }
}
