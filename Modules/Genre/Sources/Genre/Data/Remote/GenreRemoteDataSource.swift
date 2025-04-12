//
//  Untitled.swift
//  Genre
//
//  Created by Zahra Nurul Izza on 12/04/25.
//
import Core
import Foundation
import Alamofire
@preconcurrency import RxSwift

public struct GenreRemoteDataSource: RemoteDataSource {
    public typealias Request = Any
    public typealias Response = GenreRes

    private let _networkService: NetworkService

    public init() {
        self._networkService = NetworkService.shared
    }

    public func execute(req: Any) -> Observable<GenreRes> {
        let url = _networkService.buildUrl(endpoint: "/genres", parameters: nil)
        return _networkService.request(url: url)
    }
}
