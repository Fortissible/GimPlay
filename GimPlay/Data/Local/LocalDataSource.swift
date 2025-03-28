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
    
    func getAllFavouriteGames(query: String? = nil, completion: @escaping(_ games: [GameModel]) -> Void) async {
        let taskContext = newTaskContext()
        
        do {
            try await taskContext.perform {
                let fetchReq = NSFetchRequest<NSManagedObject>(entityName: "GameDetailEntities")
                
                // HANDLE QUERY FILTERING
                var predicates: [NSPredicate] = []
                
                if let query = query, !query.isEmpty {
                    let components = query.split(separator: " ", maxSplits: 2).map { String($0) }
                    if components.first?.starts(with: "FilterByGenreId:") == true {
                        // Extract Genre ID
                        if let genreId = Int(components[1]) {
                            predicates.append(NSPredicate(format: "ANY genres.id == %d", genreId))
                        }
                        
                        // Extract game title if provided
                        if components.count > 2 {
                            let gameTitle = components[2]
                            predicates.append(NSPredicate(format: "name CONTAINS[cd] %@", gameTitle))
                        }
                    } else {
                        // If no FilterByGenreId, treat the whole query as a game title search
                        predicates.append(NSPredicate(format: "name CONTAINS[cd] %@", query))
                    }
                }
                
                // APPLY PREDICATES
                if !predicates.isEmpty {
                    fetchReq.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
                }
                
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
                        backgroundImage: result.value(forKeyPath: "imageUrl") as? String,
                        genres: self.getGameGenres(gameEntity: gameEntity),
                        isFavourite: true
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
                        description: gameEntity.descriptions ?? "",
                        rating: gameEntity.rating,
                        ratingTop: Int(gameEntity.ratingTop),
                        metacritic: Int(gameEntity.metacritic),
                        backgroundImage: gameEntity.imageUrl ?? "",
                        genres: self.getGameGenres(gameEntity: gameEntity),
                        stores: gameDetailStores,
                        playtime: Int(gameEntity.playtime),
                        reviewsCount: Int(gameEntity.playtime),
                        publisher: gameEntity.publisher ?? "",
                        isFavourite: true
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
    
    func isGameInLocal(id: Int) async -> Bool {
        let taskContext = newTaskContext()
        var exists = false
        
        do {
            try await taskContext.perform {
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "GameDetailEntities")
                fetchRequest.predicate = NSPredicate(format: "id == \(id)")
                fetchRequest.fetchLimit = 1
                
                let count = try taskContext.count(for: fetchRequest)
                exists = count > 0
            }
        } catch let error as NSError{
            print("Error checking game existence: \(error.localizedDescription), \(error.userInfo)")
        }
        
        return exists
    }

    
    func getAllFavouriteGenres(completion: @escaping(_ genres: [GenreModel]) -> Void) async {
        let taskContext = newTaskContext()
        do {
            try await taskContext.perform {
                let fetchReq = NSFetchRequest<NSManagedObject>(entityName: "GenreEntities")
                
                let results = try taskContext.fetch(fetchReq)
                
                var genres: [GenreModel] = []
                for result in results {
                    let genre = GenreModel(
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
    
    func deleteUnusedGenres() async {
        let taskContext = newTaskContext()

        await taskContext.perform {
            let fetchRequest = NSFetchRequest<GenreEntities>(entityName: "GenreEntities")

            do {
                let genres = try taskContext.fetch(fetchRequest)

                for genre in genres {
                    if genre.games?.count == 0 {
                        taskContext.delete(genre)
                    }
                }

                try taskContext.save()
            } catch {
                print("Error deleting unused genres: \(error)")
            }
        }
    }
    
    func fetchGenreById(genreId: Int, context: NSManagedObjectContext) -> GenreEntities? {
        let fetchRequest = NSFetchRequest<GenreEntities>(entityName: "GenreEntities")
        fetchRequest.predicate = NSPredicate(format: "id == \(genreId)")
        fetchRequest.fetchLimit = 1

        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Error fetching genre by ID: \(error)")
            return nil
        }
    }
    
    func addFavouriteGame(
        _ gameDetailModel: GameDetailModel,
        completion: @escaping() -> Void
    ) {
        let taskContext = newTaskContext()
        
        do {
            try taskContext.performAndWait {
                if let entity = NSEntityDescription.entity(
                    forEntityName: "GameDetailEntities",
                    in: taskContext
                ) {
                    let gameDetail = NSManagedObject(
                        entity: entity,
                        insertInto: taskContext
                    )
                    let storesString = gameDetailModel.stores.joined(separator: ", ")
                    
                    gameDetail.setValue(
                        gameDetailModel.id, forKeyPath: "id")
                    gameDetail.setValue(
                        gameDetailModel.name, forKeyPath: "name")
                    gameDetail.setValue(
                        gameDetailModel.released, forKeyPath: "released")
                    gameDetail.setValue(
                        gameDetailModel.description, forKeyPath: "descriptions")
                    gameDetail.setValue(
                        gameDetailModel.publisher, forKeyPath: "publisher")
                    gameDetail.setValue(
                        storesString, forKeyPath: "stores")
                    gameDetail.setValue(
                        gameDetailModel.backgroundImage, forKeyPath: "imageUrl")
                    gameDetail.setValue(
                        gameDetailModel.image, forKeyPath: "image")
                    gameDetail.setValue(
                        gameDetailModel.metacritic, forKeyPath: "metacritic")
                    gameDetail.setValue(
                        gameDetailModel.playtime, forKeyPath: "playtime")
                    gameDetail.setValue(
                        gameDetailModel.rating, forKeyPath: "rating")
                    gameDetail.setValue(
                        gameDetailModel.ratingTop, forKeyPath: "ratingTop")
                    gameDetail.setValue(
                        gameDetailModel.reviewsCount, forKeyPath: "reviewsCount")
                    
                    var genreEntities: Set<NSManagedObject> = []
                    
                    for genre in gameDetailModel.genres {
                        if let existingGenre = fetchGenreById(genreId: genre.id, context: taskContext) {
                            genreEntities.insert(existingGenre)
                            continue
                        }
                        let genreEntity = NSEntityDescription.insertNewObject(forEntityName: "GenreEntities", into: taskContext)
                        
                        genreEntity.setValue(genre.id, forKey: "id")
                        genreEntity.setValue(genre.name, forKey: "name")
                        genreEntity.setValue(genre.image?.jpegData(compressionQuality: 1.0), forKey: "image")
                        genreEntity.setValue(genre.imageBackground, forKey: "imageUrl")
                        
                        genreEntities.insert(genreEntity)
                    }
                    
                    gameDetail.setValue(genreEntities, forKey: "genres")
                    
                    try taskContext.save()
                    completion()
                }
            }
        } catch let error as NSError {
            print("Error while creating fav game: \(error.localizedDescription), \(error.userInfo)")
        }
    }
    
    func removeFavouriteGame(
        _ id: Int, completion: @escaping () -> Void
    ) async {
        let taskContext = newTaskContext()
        await taskContext.perform {
            let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "GameDetailEntities")
            fetchReq.fetchLimit = 1
            fetchReq.predicate = NSPredicate(format: "id == \(id)")
            
            let batchDelReq = NSBatchDeleteRequest(fetchRequest: fetchReq)
            batchDelReq.resultType = .resultTypeCount
            
            if let batchDelRes = try? taskContext.execute(batchDelReq) as? NSBatchDeleteResult {
                if batchDelRes.result != nil {
                    completion()
                }
            } else {
                print("Error while deleting fav game with id \(id)")
            }
        }
    }
}
