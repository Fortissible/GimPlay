//
//  Utils.swift
//  GimPlay
//
//  Created by Wildan on 18/03/25.
//

import Foundation
import CoreData
import UIKit

extension LocalDataSource {
    func mapImageData(_ result: NSManagedObject) -> DownloadableImage {
        let imageData = result.value(forKeyPath: "image") as? Data
        if  imageData != nil {
            return DownloadableImage(
                UIImage(data: imageData!),
                .done
            )
        } else {
            return DownloadableImage(
                nil,
                .new
            )
        }
    }
    
    func getGameGenres(gameEntity: GameDetailEntities) -> [GenreModel] {
        let genres = (gameEntity.genres as? Set<GenreEntities>)?.map { genreEntity in
            GenreModel(
                id: Int(genreEntity.id),
                name: genreEntity.name ?? "",
                imageBackground: genreEntity.imageUrl ?? ""
            )
        } ?? []
        
        return genres
    }
}
