//
//  GameDetailInteractor.swift
//  GameDetail
//
//  Created by Zahra Nurul Izza on 14/04/25.
//
import Foundation
import RxSwift
import Core

public struct GameDetailInteractor: UseCase {
    public typealias Request = GameDetailRepositoryRequest
    public typealias Response = GameDetailRepositoryResponse
    public typealias Repository = GameDetailRepository<GameDetailLocalDataSource, GameDetailRemoteDataSource, GameDetailDataMapper>

    private let repository: Repository

    public init(repository: Repository) {
        self.repository = repository
    }

    public func execute(request: GameDetailRepositoryRequest) -> Observable<GameDetailRepositoryResponse> {
        repository.execute(request: request)
    }
}
