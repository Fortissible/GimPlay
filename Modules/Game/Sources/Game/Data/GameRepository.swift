//
//  GameRepository.swift
//  Game
//
//  Created by Zahra Nurul Izza on 11/04/25.
//
import Core
import RxSwift

public enum GameRepositoryRequest {
    case fetchAllRemote(GameRequestType)
    case fetchAllLocal(String?)
}

public struct GameRepository<
    GameLocalDataSource: LocalDataSource,
    GameRemoteDataSource: RemoteDataSource,
    GameDataMapper: DataMapper
>: Repository {
    public typealias Request = GameRepositoryRequest
    public typealias Response = [GameModel]

    private let _localDS : GameLocalDataSource
    private let _remoteDS : GameRemoteDataSource
    private let _mapper: GameDataMapper

    public init(
        localDataSource: GameLocalDataSource,
        remoteDataSource: GameRemoteDataSource,
        dataMapper: GameDataMapper
    ) {
        self._localDS = localDataSource
        self._remoteDS = remoteDataSource
        self._mapper = dataMapper
    }

    public func execute(request: GameRepositoryRequest) -> Observable<[GameModel]> {
        switch request {
        case .fetchAllRemote(let remoteReq):
            return fetchAllRemote(req: remoteReq)
        case .fetchAllLocal(let localReq):
            return fetchAllLocal(req: localReq)
        }
    }

    private func fetchAllRemote(req: GameRequestType) -> Observable<[Response]> {
        return _remoteDS.execute(req: req as! GameRemoteDataSource.Request)
            .map { result in
                _mapper.transformResponseToDomain(response: result as! GameDataMapper.Response)
            }
    }

    private func fetchAllLocal(req: String?) -> Observable<[Response]> {
        return _localDS.getList(request: req as! GameLocalDataSource.ListRequest)
            .map { result in
                _mapper.transformEntitiesToDomain(entities: result)
            }
    }
}
