//
//  GenreRepository.swift
//  Genre
//
//  Created by Zahra Nurul Izza on 12/04/25.
//
import Core
import RxSwift

public enum GenreRepositoryRequest {
    case fetchGenresRemote
    case fetchGenresLocal
    case deleteGenresLocal
}

public enum GenreRepositoryResponse {
    case boolResponse(Bool)
    case modelsResponse([GenreModel])
}

public struct GenreRepository<
    GenreLocalDataSource: LocalDataSource,
    GenreRemoteDataSource: RemoteDataSource,
    GenreDataMapper: DataMapper
>: Repository {
    public typealias Request = GenreRepositoryRequest
    public typealias Response = GenreRepositoryResponse

    private let _localDS: GenreLocalDataSource
    private let _remoteDS: GenreRemoteDataSource
    private let _mapper: GenreDataMapper

    public init(
        localDS: GenreLocalDataSource,
        remoteDS: GenreRemoteDataSource,
        mapper: GenreDataMapper
    ) {
        self._localDS = localDS
        self._remoteDS = remoteDS
        self._mapper = mapper
    }

    public func execute(request: Request) -> Observable<Response> {
        switch request {
        case .fetchGenresRemote:
            fetchGenresRemote(req: nil)
        case .fetchGenresLocal:
            fetchGenresLocal(req: nil)
        case .deleteGenresLocal:
            deleteGenresLocal(req: nil)
        }
    }

    private func fetchGenresRemote(req: Any?) -> Observable<Response> {
        return _remoteDS.execute(req: req as! GenreRemoteDataSource.Request)
            .map { result in
                _mapper.transformResponseToDomain(response: result as! GenreDataMapper.Response)
            }
            .map { result in
                GenreRepositoryResponse.modelsResponse(result as! [GenreModel])
            }
    }

    private func fetchGenresLocal(req: Any?) -> Observable<Response> {
        return _localDS.getList(request: req as! GenreLocalDataSource.ListRequest)
            .map { result in
                _mapper.transformEntitiesToDomain(entities: result as! GenreDataMapper.Entities)
            }
            .map { result in
                GenreRepositoryResponse.modelsResponse(result as! [GenreModel])
            }
    }

    private func deleteGenresLocal(req: Any?) -> Observable<Response> {
        return _localDS.delete(id: nil)
            .map { result in
                GenreRepositoryResponse.boolResponse(result)
            }
    }
}
