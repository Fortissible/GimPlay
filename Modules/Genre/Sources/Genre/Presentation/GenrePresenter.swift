//
//  GenrePresenter.swift
//  Genre
//
//  Created by Zahra Nurul Izza on 13/04/25.
//

import RxSwift
import Core

public enum GenrePresenterRequest {
    case fetchGenresRemote
    case fetchGenresLocal
    case deleteGenresLocal
}

public enum GenrePresenterResponse {
    case genresResponse([GenreModel])
}

public class GenrePresenter<
    Interactor: UseCase
>: Presenter where Interactor.Request == GenreRepositoryRequest, Interactor.Response == GenreRepositoryResponse {

    public typealias Request = GenrePresenterRequest
    public typealias Response = GenrePresenterResponse

    private let useCase: Interactor
    private let disposeBag: DisposeBag

    // Reactive Vars
    let genres = PublishSubject<[GenreModel]>()
    let error = PublishSubject<String>()

    public init(useCase: Interactor) {
        self.useCase = useCase
        self.disposeBag = DisposeBag()
    }

    public func execute(request: Request) {
        switch request {
        case .fetchGenresRemote:
            fetchGenresRemote()
        case .fetchGenresLocal:
            fetchGenresLocal()
        case .deleteGenresLocal:
            deleteGenresLocal()
        }
    }

    private func fetchGenresRemote() {
        useCase.execute(request: .fetchGenresRemote)
            .subscribe(
                onNext: { response in
                    if case .modelsResponse(let genres) = response {
                        self.genres.onNext(genres)
                    }
                },
                onError: { error in
                    self.error.onNext(error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }

    private func fetchGenresLocal() {
        useCase.execute(request: .fetchGenresLocal)
            .subscribe(
                onNext: { response in
                    if case .modelsResponse(let genres) = response {
                        self.genres.onNext(genres)
                    }
                },
                onError: { error in
                    self.error.onNext(error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }

    private func deleteGenresLocal() {
        useCase.execute(request: .deleteGenresLocal)
            .subscribe(
                onNext: { _ in
                },
                onError: { _ in
                }
            )
            .disposed(by: disposeBag)
    }
}
