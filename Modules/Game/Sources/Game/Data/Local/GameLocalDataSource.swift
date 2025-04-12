//
//  GameLocalDataSource.swift
//  Game
//
//  Created by Zahra Nurul Izza on 11/04/25.
//
import Core
import RxSwift
import RealmSwift

public struct GameLocalDataSource: LocalDataSource {
    public typealias Response = GameDetailEntity

    public typealias ListRequest = String?

    public typealias ModelRequest = GameDetailModel

    private let realm: Realm?

    public init(realm: Realm) {
        self.realm = realm
    }

    public func getList(request: String?) -> Observable<[GameDetailEntity]> {
        return Observable.create { observer in
            if let realm = self.realm {
                var results = realm.objects(GameDetailEntity.self)

                // HANDLE QUERY FILTERING
                if let query = request, !query.isEmpty {
                    let components = query.split(separator: " ", maxSplits: 2).map { String($0) }

                    if components.first?.starts(with: "FilterByGenreId:") == true {
                        // Extract Genre ID
                        if let genreId = Int(components[1]) {
                            results = results.filter("ANY genres.id == %@", String(genreId))
                        }

                        // Extract game title if provided
                        if components.count > 2 {
                            let gameTitle = components[2]
                            results = results.filter("name CONTAINS[cd] %@", gameTitle)
                        }
                    } else {
                        // If no FilterByGenreId, treat the whole query as a game title search
                        results = results.filter("name CONTAINS[cd] %@", query)
                    }
                }

                observer.onNext(results.toArray(ofType: GameDetailEntity.self))
                observer.onCompleted()
            } else {
                observer.onError(DatabaseError.invalidInstance)
            }

            return Disposables.create()
        }
    }

    public func getDetail(id: Int) -> Observable<GameDetailEntity> {
        fatalError("Unimplemented Function")
    }

    public func add(model: GameDetailModel) -> Observable<Bool> {
        fatalError("Unimplemented Function")
    }

    public func delete(id: Int?) -> Observable<Bool> {
        fatalError("Unimplemented Function")
    }

    public func check(id: Int) -> Observable<Bool> {
        fatalError("Unimplemented Function")
    }
}
