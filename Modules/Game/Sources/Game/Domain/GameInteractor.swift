//
//  GameInteractor.swift
//  Game
//
//  Created by Zahra Nurul Izza on 14/04/25.
//

import Foundation
import RxSwift
import Core

public struct GameInteractor: UseCase {
    public typealias Request = GameRepositoryRequest
    public typealias Response = [GameModel]
    public typealias Repository = GameRepository<GameLocalDataSource, GameRemoteDataSource, GameDataMapper>

    private let repository: Repository

    public init(repository: Repository) {
        self.repository = repository
    }

    public func execute(request: GameRepositoryRequest) -> Observable<[GameModel]> {
        repository.execute(request: request)
    }
}
