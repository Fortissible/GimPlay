//
//  LocalDataSource.swift
//  GimPlay
//
//  Created by Wildan on 18/03/25.
//

import Foundation
import RealmSwift
import RxSwift

protocol ILocalDataSource {
    func getAllFavouriteGames(query: String?) -> Observable<[GameDetailEntity]>
    func getAllFavouriteGenres() -> Observable<[GenreEntity]>

    func getFavouriteGame(_ id: Int) -> Observable<GameDetailEntity>
    func fetchGenreById(genreId: Int) -> Observable<GenreEntity>

    func addFavouriteGame(_ gameDetailModel: GameDetailModel) -> Observable<Bool>

    func removeFavouriteGame(_ id: Int) -> Observable<Bool>
    func deleteUnusedGenres() -> Observable<Bool>

    func isGameInLocal(id: Int) -> Observable<Bool>
}

class LocalDataSource: ILocalDataSource {
    private let realm: Realm?

    private init(realm: Realm?) {
        self.realm = realm
    }

    static let sharedInstance: (Realm?) -> LocalDataSource = { realmDb in
        return LocalDataSource(realm: realmDb)
    }
}

extension LocalDataSource {
    func getAllFavouriteGames(query: String?) -> Observable<[GameDetailEntity]> {
        return Observable.create { observer in
            if let realm = self.realm {
                var results = realm.objects(GameDetailEntity.self)

                // HANDLE QUERY FILTERING
                if let query = query, !query.isEmpty {
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

    func getFavouriteGame(_ id: Int) -> Observable<GameDetailEntity> {
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

    func isGameInLocal(id: Int) -> Observable<Bool> {
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

    func getAllFavouriteGenres() -> Observable<[GenreEntity]> {
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

    func deleteUnusedGenres() -> Observable<Bool> {
        return Observable.create { observer in
            // Ensure we have a valid Realm instance
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

    func fetchGenreById(genreId: Int) -> Observable<GenreEntity> {
        return Observable.create { observer in
            guard let realm = self.realm else {
                observer.onError(DatabaseError.invalidInstance)
                return Disposables.create()
            }

            if let result = realm.object(ofType: GenreEntity.self, forPrimaryKey: genreId) {
                observer.onNext(result)
                observer.onCompleted()
            } else {
                observer.onError(DatabaseError.notFound)
            }

            return Disposables.create()
        }
    }

    func addFavouriteGame(_ gameDetailModel: GameDetailModel) -> Observable<Bool> {
        return Observable.create { observer in
            guard let realm = self.realm else {
                observer.onError(DatabaseError.invalidInstance)
                return Disposables.create()
            }

            do {
                try realm.write {
                    let gameDetailEntity = GameDetailEntity(detail: gameDetailModel)

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

    func removeFavouriteGame(_ id: Int) -> Observable<Bool> {
        return Observable.create { observer in
            guard let realm = self.realm else {
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
}

extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for index in 0 ..< count {
            if let result = self[index] as? T {
                array.append(result)
            }
        }
        return array
    }
}
