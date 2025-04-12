//
//  GameDetailLocalDataSource.swift
//  GameDetail
//
//  Created by Zahra Nurul Izza on 12/04/25.
//
import Core
import RxSwift

public struct GameDetailLocalDataSource: LocalDataSource {
    public typealias Response = GameDetailEntity

    public typealias ListRequest = Any

    public typealias ModelRequest = GameDetailModel

    public func getList(request: Any) -> Observable<[GameDetailEntity]> {
        fatalError("Unimplemented Function")
    }

    public func getDetail(id: Int) -> Observable<GameDetailEntity> {
        fatalError("Unimplemented Function")
    }

    public func add(entity: GameDetailModel) -> Observable<Bool> {
        fatalError("Unimplemented Function")
    }

    public func delete(id: Int?) -> Observable<Bool> {
        fatalError("Unimplemented Function")
    }

    public func check(id: Int) -> Observable<Bool> {
        fatalError("Unimplemented Function")
    }
}
