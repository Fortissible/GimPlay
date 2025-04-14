//
//  ImageDownloader.swift
//  Core
//
//  Created by Zahra Nurul Izza on 14/04/25.
//
import Foundation

public class ImageDownloader: @unchecked Sendable {
    private let urlSession: URLSession
    private let cache: NSCache<NSURL, NSData>

    public init(urlSession: URLSession = .shared, cache: NSCache<NSURL, NSData> = NSCache()) {
        self.urlSession = urlSession
        self.cache = cache
    }

    public func downloadImage(from url: URL) async throws -> Data {
        // Check cache first
        if let cachedData = cache.object(forKey: url as NSURL) {
            return cachedData as Data
        }

        // Download with proper error handling
        let (data, response) = try await urlSession.data(from: url)

        // Validate response
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError.invalidResponse
        }

        // Validate content type
        if let mimeType = httpResponse.mimeType,
           !mimeType.hasPrefix("image") {
            throw URLError.invalidResponse
        }

        // Cache the downloaded data
        cache.setObject(data as NSData, forKey: url as NSURL)

        return data
    }

}
