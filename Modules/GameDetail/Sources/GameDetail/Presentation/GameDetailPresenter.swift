//
//  GameDetailPresenter.swift
//  GameDetail
//
//  Created by Zahra Nurul Izza on 13/04/25.
//

import RxSwift
import Core

public enum GameDetailPresenterRequest {
    case fetchDetailRemote(String)
    case fetchDetailLocal(Int)
    case addDetailLocal(GameDetailModel)
    case deleteDetailLocal(Int?)
    case checkDetailInLocal(Int)
}

public enum GameDetailPresenterResponse {
    case gameDetailResponse(GameDetailModel)
}

public class GameDetailPresenter<
    Interactor: UseCase
>: Presenter where
Interactor.Request == GameDetailRepositoryRequest,
Interactor.Response == GameDetailRepositoryResponse {

    public typealias Request = GameDetailPresenterRequest
    public typealias Response = GameDetailPresenterResponse

    private let useCase: Interactor
    private let disposeBag: DisposeBag

    // Reactive Vars
    let gameDetail = PublishSubject<GameDetailModel>()
    let isFavourite = PublishSubject<Bool>()
    let error = PublishSubject<String>()

    public init(useCase: Interactor) {
        self.useCase = useCase
        self.disposeBag = DisposeBag()
    }

    public func execute(request: Request) {
        switch request {
        case .fetchDetailRemote(let id):
            fetchDetailRemote(id: id)
        case .addDetailLocal(let gameDetailModel):
            addDetailLocal(gameDetailModel: gameDetailModel)
        case .deleteDetailLocal(let id):
            deleteDetailLocal(id: id)
        case .checkDetailInLocal(let id):
            checkDetailInLocal(id: id)
        case .fetchDetailLocal(let id):
            fetchDetailLocal(id: id)
        }
    }

    private func fetchDetailRemote(id: String) {
        useCase.execute(request: .fetchDetailRemote(id))
            .subscribe(
                onNext: { res in
                    if case GameDetailRepositoryResponse.ModelResponse(let gameDetailModel) = res {
                        self.gameDetail.onNext(gameDetailModel)
                    }
                },
                onError: { error in
                    self.error.onNext(error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }

    private func fetchDetailLocal(id: Int) {
        useCase.execute(request: .fetchDetailLocal(id))
            .subscribe(
                onNext: { res in
                    if case GameDetailRepositoryResponse.ModelResponse(let gameDetailModel) = res {
                        self.gameDetail.onNext(gameDetailModel)
                    }
                },
                onError: { error in
                    self.error.onNext(error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }

    private func addDetailLocal(gameDetailModel: GameDetailModel) {
        useCase.execute(request: .addDetailLocal(gameDetailModel))
            .subscribe(
                onNext: { res in
                    if case GameDetailRepositoryResponse.BoolResponse(let isSuccess) = res {
                        self.isFavourite.onNext(isSuccess)
                    }
                },
                onError: { error in
                    self.error.onNext(error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }

    private func deleteDetailLocal(id: Int?) {
        useCase.execute(request: .deleteDetailLocal(id))
            .subscribe(
                onNext: { res in
                    if case GameDetailRepositoryResponse.BoolResponse(let isSuccess) = res {
                        self.isFavourite.onNext(!isSuccess)
                    }
                },
                onError: { error in
                    self.error.onNext(error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }

    private func checkDetailInLocal(id: Int) {
        useCase.execute(request: .checkDetailInLocal(id))
            .subscribe(
                onNext: { result in
                    if case GameDetailRepositoryResponse.BoolResponse(let isFavorite)
                        = result {
                        self.isFavourite.onNext(isFavorite)
                    }
                }
            )
            .disposed(by: disposeBag)
    }
}
