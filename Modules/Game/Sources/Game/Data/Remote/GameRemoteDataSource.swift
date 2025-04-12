//
//  RemoteDataSource.swift
//  Game
//
//  Created by Zahra Nurul Izza on 11/04/25.
//

import Foundation
import Core
@preconcurrency import RxSwift
import Alamofire

public struct GameRequestType: Decodable {
    let query: String
    let genreId: String?
    let searchQuery: String?
    let page: Int?
}

public struct GameRemoteDataSource: RemoteDataSource {
    public typealias Request = GameRequestType
    public typealias Response = GamesRes

    private let _networkService: NetworkService

    public init() {
        self._networkService = NetworkService.shared
    }

    public func execute(req: GameRequestType) -> Observable<GamesRes> {
        var parameters: [String: String] = [
            "page": "\(req.page ?? 1)"
            ]

        if let searchQuery = req.searchQuery {
            parameters["search"] = searchQuery
        }

        if req.query == "released" {
            parameters["ordering"] = "-released"
        } else if req.query != "lucky" {
            parameters["ordering"] = req.query
        }

        if let genreId = req.genreId {
            parameters["genres"] = genreId
        }

        let url = _networkService.buildUrl(endpoint: "/games", parameters: parameters)
        return _networkService.request(url: url)
    }
}
