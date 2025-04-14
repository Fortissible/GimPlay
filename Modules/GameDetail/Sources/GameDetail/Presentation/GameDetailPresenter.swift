//
//  GameDetailPresenter.swift
//  GameDetail
//
//  Created by Zahra Nurul Izza on 13/04/25.
//

import RxSwift
import Core

public enum GameDetailPresenterRequest {
    case fetchDetail(String)
    case addDetailLocal(GameDetailModel)
    case deleteDetailLocal(Int?)
    case checkDetailInLocal(Int)
}

public enum GameDetailPresenterResponse {
    case gameDetailResponse(GameDetailModel)
}

public class GameDetailPresenter<
    GameDetailInteractor: UseCase
>: Presenter where
GameDetailInteractor.Request == GameDetailRepositoryRequest,
GameDetailInteractor.Response == GameDetailRepositoryResponse {

    public typealias Request = GameDetailPresenterRequest
    public typealias Response = GameDetailPresenterResponse

    private let useCase: GameDetailInteractor
    private let disposeBag: DisposeBag

    // Reactive Vars
    public let gameDetail = PublishSubject<GameDetailModel>()
    public let isFavourite = PublishSubject<Bool>()
    public let error = PublishSubject<String>()

    public init(useCase: GameDetailInteractor) {
        self.useCase = useCase
        self.disposeBag = DisposeBag()
    }

    public func execute(request: Request) {
        switch request {
        case .fetchDetail(let id):
            fetchDetail(id: id)
        case .addDetailLocal(let gameDetailModel):
            addDetailLocal(gameDetailModel: gameDetailModel)
        case .deleteDetailLocal(let id):
            deleteDetailLocal(id: id)
        case .checkDetailInLocal(let id):
            checkDetailInLocal(id: id)
        }
    }

    private func fetchDetail(id: String) {
        useCase.execute(request: .checkDetailInLocal(Int(id) ?? 0))
            .subscribe(
                onNext: { result in
                    if case GameDetailRepositoryResponse.BoolResponse(let isFavorite)
                        = result {
                        if isFavorite {
                            print("DEBUG: REMOTE DETAIL TRIGGERED")
                            self.detailLocal(id: Int(id) ?? 0)
                        } else {
                            print("DEBUG: REMOTE DETAIL TRIGGERED")
                            self.detailRemote(id: id)
                        }
                    }
                }
            )
            .disposed(by: disposeBag)
    }

    private func detailLocal(id: Int) {
        useCase.execute(request: .fetchDetailLocal(id))
            .subscribe(
                onNext: { res in
                    if case GameDetailRepositoryResponse.ModelResponse(let gameDetailModel) = res {
                        print("DEBUG: LOCAL DETAIL RETRIEVED \(gameDetailModel.name)")
                        self.gameDetail.onNext(gameDetailModel)
                        self.isFavourite.onNext(true)
                    }
                },
                onError: { error in
                    self.error.onNext(error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }

    private func detailRemote(id: String) {
        useCase.execute(request: .fetchDetailRemote(id))
            .subscribe(
                onNext: { res in
                    if case GameDetailRepositoryResponse.ModelResponse(let gameDetailModel) = res {
                        print("DEBUG: REMOTE DETAIL RETRIEVED \(gameDetailModel.name)")
                        self.gameDetail.onNext(gameDetailModel)
                        self.isFavourite.onNext(false)
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
