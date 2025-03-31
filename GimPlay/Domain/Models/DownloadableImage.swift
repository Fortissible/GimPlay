//
//  DownloadableImage.swift
//  GimPlay
//
//  Created by Wildan on 10/03/25.
//

import Foundation
import UIKit

enum ViewType {
    case gameTable
    case genreCollection
}

class DownloadableImage {
    var image: UIImage?
    var state: NetworkState = .new

    init(_ image: UIImage? = nil, _ state: NetworkState = .new) {
        self.image = image
        self.state = state
    }
}
