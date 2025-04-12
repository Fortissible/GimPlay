//
//  DownloadableImage.swift
//  GimPlay
//
//  Created by Wildan on 10/03/25.
//

import Foundation

public enum ViewType {
    case gameTable
    case genreCollection
}

public class DownloadableImage {
    var image: Data?
    var state: NetworkState = .new

    public init(_ image: Data? = nil, _ state: NetworkState = .new) {
        self.image = image
        self.state = state
    }
}
