//
//  GameDetailLocalDataSource.swift
//  GameDetail
//
//  Created by Zahra Nurul Izza on 12/04/25.
//
import Core
import RxSwift
import RealmSwift

public struct GameDetailLocalDataSource: LocalDataSource {
    public typealias Response = GameDetailEntity

    public typealias ListRequest = Any

    public typealias ModelRequest = GameDetailModel

    private let realm: Realm?

    public init(realm: Realm) {
        self.realm = realm
    }

    public func getDetail(id: Int) -> Observable<GameDetailEntity> {
        return Observable.create { observer in
            guard let realm = self.realm else {
                observer.onError(DatabaseError.invalidInstance)
                return Disposables.create()
            }

            if let game = realm.object(ofType: GameDetailEntity.self, forPrimaryKey: id) {
                observer.onNext(game)
                observer.onCompleted()
            } else {
                observer.onError(DatabaseError.notFound)
            }

            return Disposables.create()
        }
    }

    public func add(entity: GameDetailModel) -> Observable<Bool> {
        return Observable.create { observer in
            guard let realm = self.realm else {
                observer.onError(DatabaseError.invalidInstance)
                return Disposables.create()
            }

            do {
                try realm.write {
                    let gameDetailEntity = GameDetailEntity(detail: entity)

                    realm.add(gameDetailEntity, update: .all)
                }
                observer.onNext(true)
                observer.onCompleted()
            } catch {
                observer.onError(DatabaseError.requestFailed)
            }

            return Disposables.create()
        }
    }

    public func delete(id: Int?) -> Observable<Bool> {
        return Observable.create { observer in
            guard let realm = self.realm, let id = id else {
                observer.onError(DatabaseError.invalidInstance)
                return Disposables.create()
            }

            do {
                try realm.write {
                    if let game = realm.object(ofType: GameDetailEntity.self, forPrimaryKey: id) {
                        realm.delete(game)

                        observer.onNext(true)
                    } else {
                        observer.onNext(false)
                    }
                    observer.onCompleted()
                }
            } catch {
                observer.onError(error)
            }

            return Disposables.create()
        }
    }

    public func check(id: Int) -> Observable<Bool> {
        return Observable.create { observer in
            guard let realm = self.realm else {
                observer.onError(DatabaseError.invalidInstance)
                return Disposables.create()
            }

            if realm.object(ofType: GameDetailEntity.self, forPrimaryKey: id) != nil {
                observer.onNext(true)
                observer.onCompleted()
            } else {
                observer.onNext(false)
                observer.onCompleted()
            }

            return Disposables.create()
        }
    }

    public func getList(request: Any) -> Observable<[GameDetailEntity]> {
        fatalError("Unimplemented Function")
    }
}
