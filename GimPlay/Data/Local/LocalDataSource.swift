//
//  LocalDataSource.swift
//  GimPlay
//
//  Created by Wildan on 18/03/25.
//

import Foundation
import CoreData

class LocalDataSource {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "GameLocalModel")
        
        container.loadPersistentStores { _, error in
            guard error == nil else {
                fatalError("Error loading persistent stores \(error!)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = false
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.shouldDeleteInaccessibleFaults = true
        container.viewContext.undoManager = nil
        
        return container
    }()
    
    private func newTaskContext() -> NSManagedObjectContext {
        let taskContext = persistentContainer.newBackgroundContext()
        taskContext.undoManager = nil
        
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return taskContext
    }
    
    func getAllFavouriteGames(completion: @escaping(_ games: [GameModel]) -> Void) async {
        let taskContext = newTaskContext()
        
        do {
            try await taskContext.perform {
                let fetchReq = NSFetchRequest<NSManagedObject>(entityName: "GameDetailEntities")
                
                let results = try taskContext.fetch(fetchReq)
                
                var games: [GameModel] = []
                for result in results {
                    // USE CORE DATA ENTITIES CASTING
                    let gameEntity = result as! GameDetailEntities
                    
                    // USE MANUAL CASTING
                    let game = GameModel(
                        id: result.value(forKeyPath: "id") as? Int ?? 0,
                        name: result.value(forKeyPath: "name") as? String ?? "",
                        released: result.value(forKeyPath: "released") as? String,
                        rating: result.value(forKeyPath: "rating") as? Double ?? 0.0,
                        ratingTop: result.value(forKeyPath: "ratingTop") as? Int ?? 5,
                        metacritic: result.value(forKeyPath: "metacritic") as? Int,
                        backgroundImage: result.value(forKeyPath: "url") as? String,
                        genres: self.getGameGenres(gameEntity: gameEntity)
                    )
                    
                    games.append(game)
                }
                
                completion(games)
            }
        } catch let error as NSError {
            print("Error while fetch fav game list: \(error.localizedDescription), \(error.userInfo)")
        }
    }
    
    func getFavouriteGame(_ id: Int, completion: @escaping(_ game: GameDetailModel) -> Void) async {
        let taskContext = newTaskContext()
        
        do {
            try await taskContext.perform {
                let fetchReq = NSFetchRequest<NSManagedObject>(entityName: "GameDetailEntities")
                fetchReq.fetchLimit = 1
                fetchReq.predicate = NSPredicate(format: "id == \(id)")
                
                if let result = try taskContext.fetch(fetchReq).first {
                    
                    let gameEntity = result as! GameDetailEntities
                    let gameDetailStores = (gameEntity.stores ?? "").components(separatedBy: ", ")
                    let gameDetail = GameDetailModel(
                        id: Int(gameEntity.id),
                        name: gameEntity.name ?? "",
                        released: gameEntity.released ?? "",
                        description: gameEntity.description,
                        rating: gameEntity.rating,
                        ratingTop: Int(gameEntity.ratingTop),
                        metacritic: Int(gameEntity.metacritic),
                        backgroundImage: gameEntity.imageUrl ?? "",
                        genres: self.getGameGenres(gameEntity: gameEntity),
                        stores: gameDetailStores,
                        playtime: Int(gameEntity.playtime),
                        reviewsCount: Int(gameEntity.playtime),
                        publisher: gameEntity.publisher ?? ""
                    )
                    
                    let downloadableImage = self.mapImageData(result)
                    gameDetail.state = downloadableImage.state
                    gameDetail.image = downloadableImage.image
                    
                    completion(gameDetail)
                }
            }
        } catch let error as NSError {
            print("Error while fetch game detail fav: \(error.localizedDescription), \(error.userInfo)")
        }
    }
    
    func getAllFavouriteGenres(completion: @escaping(_ genres: [GenreModel]) -> Void) async {
        let taskContext = newTaskContext()
        do {
            try await taskContext.perform {
                let fetchReq = NSFetchRequest<NSManagedObject>(entityName: "GenreEntities")
                
                let results = try taskContext.fetch(fetchReq)
                
                var genres: [GenreModel] = []
                for result in results {
                    var genre = GenreModel(
                        id: result.value(forKeyPath: "id") as? Int ?? 0,
                        name: result.value(forKeyPath: "name") as? String ?? "",
                        imageBackground: result.value(forKeyPath: "imageUrl") as? String ?? ""
                    )
                    
                    let downloadableImage = self.mapImageData(result)
                    genre.state = downloadableImage.state
                    genre.image = downloadableImage.image
                    
                    genres.append(genre)
                }
                
                completion(genres)
            }
        } catch let error as NSError {
            print("Error while fetch genres: \(error.localizedDescription), \(error.userInfo)")
        }
    }
    
    // DO THE CREATE & DELETE FAV TO COREDATA
}
