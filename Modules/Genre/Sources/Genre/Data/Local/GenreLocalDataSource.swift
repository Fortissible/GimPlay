//
//  GenreDataSource.swift
//  Genre
//
//  Created by Zahra Nurul Izza on 12/04/25.
//
import Core
import RxSwift
import RealmSwift

public struct GenreLocalDataSource: LocalDataSource {
    public typealias Response = GenreEntity

    public typealias ListRequest = Any

    public typealias ModelRequest = Any

    private let realm: Realm?

    public init(realm: Realm) {
        self.realm = realm
    }

    public func getList(request: Any) -> Observable<[GenreEntity]> {
        return Observable.create { observer in
            guard let realm = self.realm else {
                observer.onError(DatabaseError.invalidInstance)
                return Disposables.create()
            }

            let results = realm.objects(GenreEntity.self)
            observer.onNext(results.toArray(ofType: GenreEntity.self))
            observer.onCompleted()

            return Disposables.create()
        }
    }

    public func getDetail(id: Int) -> Observable<GenreEntity> {
        return Observable.create { observer in
            guard let realm = self.realm else {
                observer.onError(DatabaseError.invalidInstance)
                return Disposables.create()
            }

            if let result = realm.object(ofType: GenreEntity.self, forPrimaryKey: id) {
                observer.onNext(result)
                observer.onCompleted()
            } else {
                observer.onError(DatabaseError.notFound)
            }

            return Disposables.create()
        }
    }

    public func add(entity: Any) -> Observable<Bool> {
        return Observable.create { observer in
            // Ensure have a valid Realm instance
            guard let realm = self.realm else {
                observer.onError(DatabaseError.invalidInstance)
                return Disposables.create()
            }

            do {
                // Write operation
                try realm.write {
                    // Fetch all genres with no games related to them
                    let unusedGenres = realm.objects(GenreEntity.self).filter("games.@count == 0")

                    // Delete unused genres
                    realm.delete(unusedGenres)
                }

                observer.onNext(true)
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }

            return Disposables.create()
        }
    }

    public func delete(id: Int?) -> Observable<Bool> {
        fatalError("Unimplemented Function")
    }
}
