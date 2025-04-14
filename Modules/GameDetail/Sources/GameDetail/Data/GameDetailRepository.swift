//
//  GameDetailRepository.swift
//  GameDetail
//
//  Created by Zahra Nurul Izza on 12/04/25.
//
import Core
import RxSwift

public enum GameDetailRepositoryRequest {
    case fetchDetailRemote(String)
    case fetchDetailLocal(Int)
    case addDetailLocal(GameDetailModel)
    case deleteDetailLocal(Int?)
    case checkDetailInLocal(Int)
}

public enum GameDetailRepositoryResponse {
    case ModelResponse(GameDetailModel)
    case BoolResponse(Bool)
}

public struct GameDetailRepository<
    GameDetailLocalDataSource: LocalDataSource,
    GameDetailRemoteDataSource: RemoteDataSource,
    GameDetailDataMapper: DataMapper
>: Repository {
    public typealias Request = GameDetailRepositoryRequest
    public typealias Response = GameDetailRepositoryResponse

    private let _localDS: GameDetailLocalDataSource
    private let _remoteDS: GameDetailRemoteDataSource
    private let _mapper: GameDetailDataMapper

    public init(
        localDataSource: GameDetailLocalDataSource,
        remoteDataSource: GameDetailRemoteDataSource,
        dataMapper: GameDetailDataMapper
    ) {
        _localDS = localDataSource
        _remoteDS = remoteDataSource
        _mapper = dataMapper
    }

    public func execute(request: GameDetailRepositoryRequest) -> Observable<GameDetailRepositoryResponse> {
        switch request {
        case .fetchDetailRemote(let id):
            return fetchDetailRemote(id: id)
        case .fetchDetailLocal(let id):
            return fetchDetailLocal(id: id)
        case .addDetailLocal(let gameDetailModel):
            return addDetailLocal(gameDetailModel: gameDetailModel)
        case .deleteDetailLocal(let id):
            return deleteDetailLocal(id: id)
        case .checkDetailInLocal(let id):
            return checkDetailInLocal(id: id)
        }
    }

    private func fetchDetailRemote(id: String) -> Observable<GameDetailRepositoryResponse> {
        return _remoteDS.execute(req: id as! GameDetailRemoteDataSource.Request)
            .map { result in
                _mapper.transformResponseToDomain(
                    response: result as! GameDetailDataMapper.Response
                )
            }
            .map { result in
                GameDetailRepositoryResponse.ModelResponse(result as! GameDetailModel)
            }
    }

    private func fetchDetailLocal(id: Int) -> Observable<GameDetailRepositoryResponse> {
        return _localDS.getDetail(id: id)
            .map { result in
                _mapper.transformEntitiesToDomain(
                    entities: result as! GameDetailDataMapper.Entities
                )
            }
            .map { result in
                GameDetailRepositoryResponse.ModelResponse(result as! GameDetailModel)
            }
    }

    private func addDetailLocal(gameDetailModel: GameDetailModel) -> Observable<GameDetailRepositoryResponse> {
        return _localDS.add(model: gameDetailModel as! GameDetailLocalDataSource.ModelRequest)
            .map { result in
                GameDetailRepositoryResponse.BoolResponse(result)
            }
    }

    private func deleteDetailLocal(id: Int?) -> Observable<GameDetailRepositoryResponse> {
        return _localDS.delete(id: id)
            .map { result in
                GameDetailRepositoryResponse.BoolResponse(result)
            }
    }

    private func checkDetailInLocal(id: Int) -> Observable<GameDetailRepositoryResponse> {
        print("DEBUG: LOCAL GAME CHECK \(id)")
        return _localDS.check(id: id)
            .map { result in
                GameDetailRepositoryResponse.BoolResponse(result)
            }
    }
}
