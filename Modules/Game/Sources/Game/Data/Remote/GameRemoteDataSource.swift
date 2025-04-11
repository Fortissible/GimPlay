//
//  RemoteDataSource.swift
//  Game
//
//  Created by Zahra Nurul Izza on 11/04/25.
//

import Core
import RxSwift

public struct GameRemoteDataSource: RemoteDataSource {
    public typealias Request = String
    public typealias Response = GamesRes

    public func execute(request: String?) ->
    Observable<GamesRes> {
        <#code#>
    }
}
