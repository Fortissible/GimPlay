//
//  GameLocalDataSource.swift
//  Game
//
//  Created by Zahra Nurul Izza on 11/04/25.
//
import Core
import RxSwift

public struct GameLocalDataSource: LocalDataSource {
    public typealias Response = GameDetailEntity
    
    public typealias ListRequest = String

    public typealias ModelRequest = GameDetailModel

    public func getList(request: String?) -> Observable<[GameDetailEntity]> {
        <#code#>
    }

    public func getDetail(id: Int) -> Observable<GameDetailEntity> {
        <#code#>
    }

    public func add(entity: GameDetailModel) -> Observable<Bool> {
        <#code#>
    }

    public func delete(id: Int?) -> Observable<Bool> {
        <#code#>
    }

    public func check(id: Int) -> Observable<Bool> {
        fatalError("Unimplemented Function")
    }
}
