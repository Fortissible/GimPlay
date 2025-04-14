//
//  GamePresenter.swift
//  Game
//
//  Created by Zahra Nurul Izza on 13/04/25.
//
import RxSwift
import Core
import Genre

public enum GamePresenterRequest {
    case fetchGames(String, String?, String?)
    case fetchAllLocal(String?)
}

public class GamePresenter<
    GameInteractor: UseCase
>: Presenter where
GameInteractor.Request == GameRepositoryRequest,
GameInteractor.Response == [GameModel] {

    public typealias Request = GamePresenterRequest
    public typealias Response = [GameModel]

    private let useCase: GameInteractor
    private let disposeBag: DisposeBag

    // Reactive Vars
    public let games = PublishSubject<[GameModel]>()
    public let genres = PublishSubject<[GenreModel]>()
    public let error = PublishSubject<String>()

    private var page = 1
    var isLoading = false

    public init(useCase: GameInteractor) {
        self.useCase = useCase
        self.disposeBag = DisposeBag()
    }

    public func execute(request: GamePresenterRequest) {
        switch request {
        case .fetchGames(let query, let genreId, let searchQuery):
            fetchGames(query: query, genreId: genreId, searchQuery: searchQuery)
        case .fetchAllLocal(let req):
            fetchAllLocal(req: req)
        }
    }

    private func fetchGames(query: String, genreId: String?, searchQuery: String?) {
        guard !isLoading else { return }

        isLoading = true

        useCase.execute(
            request: .fetchAllRemote(
                GameRequestType(
                    query: query,
                    genreId: genreId,
                    searchQuery: searchQuery,
                    page: self.page
                )
            )
        ).subscribe(
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

    private func fetchAllLocal(req: String?) {
        useCase.execute(request: .fetchAllLocal(req))
            .subscribe(
                onNext: { games in
                    self.games.onNext(games)
                },
                onError: { error in
                    self.error.onNext(
                        error.localizedDescription
                    )
                }
            ).disposed(by: disposeBag)
    }
}
