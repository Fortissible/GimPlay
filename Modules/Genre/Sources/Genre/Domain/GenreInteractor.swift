//
//  GenreInteractor.swift
//  Genre
//
//  Created by Zahra Nurul Izza on 14/04/25.
//

import Foundation
import RxSwift
import Core

public struct GenreInteractor: UseCase {
    public typealias Request = GenreRepositoryRequest
    public typealias Response = GenreRepositoryResponse
    public typealias Repository = GenreRepository<GenreLocalDataSource, GenreRemoteDataSource, GenreDataMapper>

    private let repository: Repository

    public init(repository: Repository) {
        self.repository = repository
    }

    public func execute(request: GenreRepositoryRequest) -> Observable<GenreRepositoryResponse> {
        return repository.execute(request: request)
    }
}
