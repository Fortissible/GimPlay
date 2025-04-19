//
//  GameDetailRemoteDataSource.swift
//  GameDetail
//
//  Created by Zahra Nurul Izza on 12/04/25.
//
import Core
@preconcurrency import RxSwift
import Foundation
import Alamofire

public struct GameDetailRemoteDataSource: RemoteDataSource {
    public typealias Request = String
    public typealias Response = GameDetailRes

    private let _networkService: NetworkService

    public init() {
        self._networkService = NetworkService.shared
    }

    public func execute(req: String) -> Observable<GameDetailRes> {
        let url = _networkService.buildUrl(endpoint: "/games/\(req)", parameters: nil)
        return _networkService.request(url: url)
    }
}
