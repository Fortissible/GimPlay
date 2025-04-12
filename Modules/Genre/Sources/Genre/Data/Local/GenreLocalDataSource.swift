//
//  GenreDataSource.swift
//  Genre
//
//  Created by Zahra Nurul Izza on 12/04/25.
//
import Core
import RxSwift

public struct GenreLocalDataSource: LocalDataSource {
    public typealias Response = GenreEntity

    public typealias ListRequest = Any

    public typealias ModelRequest = Any

    public func getList(request: Any) -> Observable<[GenreEntity]> {
        fatalError("Unimplemented Function")
    }

    public func getDetail(id: Int) -> Observable<GenreEntity> {
        fatalError("Unimplemented Function")
    }

    public func add(entity: Any) -> Observable<Bool> {
        fatalError("Unimplemented Function")
    }

    public func delete(id: Int?) -> Observable<Bool> {
        fatalError("Unimplemented Function")
    }

    public func check(id: Int) -> Observable<Bool> {
        fatalError("Unimplemented Function")
    }
}
