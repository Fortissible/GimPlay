//
//  GenreModel.swift
//  GimPlay
//
//  Created by Wildan on 09/03/25.
//

import Foundation
import UIKit

// MARK: - Result
class GenreModel : DownloadableImage {
    let id: Int
    let name: String
    let imageBackground: String

    init(
        id: Int,
        name: String,
        imageBackground: String
    ) {
        self.id = id
        self.name = name
        self.imageBackground = imageBackground
        
        super.init()
    }
}
