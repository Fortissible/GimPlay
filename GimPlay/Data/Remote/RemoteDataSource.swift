//
//  RemoteDataSource.swift
//  GimPlay
//
//  Created by Wildan on 07/03/25.
//

import Foundation

class RemoteDataSource {
    let API_KEYS = "PUT_YOUR_API_KEY_HERE"
    let BASE_URL = "https://api.rawg.io/api"
    
    lazy var queryItems: [URLQueryItem] = [
        URLQueryItem(name: "key", value: API_KEYS),
        URLQueryItem(name: "page_size", value: String(10)),
        URLQueryItem(name: "page", value: String(1))
    ]
    
    func doUrlRequest<T: Decodable>(componentsUrl: URL, dataClass: T.Type) async throws -> T {
        let request = URLRequest(url: componentsUrl)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            fatalError("Error when fetching data!")
        }
        
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            print("Decoded Data:", decodedData)
        } catch let DecodingError.dataCorrupted(context) {
            print("Data Corrupted Error: \(context)")
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key.stringValue)' not found: \(context.debugDescription)")
        } catch let DecodingError.typeMismatch(type, context) {
            print("Type mismatch for type \(type): \(context.debugDescription)")
        } catch let DecodingError.valueNotFound(type, context) {
            print("Value not found for type \(type): \(context.debugDescription)")
        } catch {
            print("Decoding Error: \(error)")
        }
        
        let result = try decoder.decode(T.self, from: data)
        
        return result
    }
    
    func getGamesFromApi(query: String, genreId: String?) async throws -> GamesRes {
        let endpoints = "/games"
        var components = URLComponents(string: "\(BASE_URL)\(endpoints)")!
        
        if query == "released" {
            queryItems.append(URLQueryItem(name: "ordering", value: "-released"))
        } else if query != "lucky" {
            queryItems.append(URLQueryItem(name: "ordering", value: query))
        }
        
        if genreId != nil {
            queryItems.append(URLQueryItem(name: "genres", value: genreId))
        }
        
        components.queryItems = queryItems
        
        return try await doUrlRequest(componentsUrl: components.url!, dataClass: GamesRes.self)
    }
    
    func getGenresFromApi() async throws -> GenreRes {
        let endpoints = "/genres"
        var components = URLComponents(string: "\(BASE_URL)\(endpoints)")!
        components.queryItems = queryItems
        
        return try await doUrlRequest(componentsUrl: components.url!, dataClass: GenreRes.self)
    }
    
    func getGameDetailFromApi(id: String) async throws -> GameDetailRes {
        let endpoints = "/games/\(id)"
        var components = URLComponents(string: "\(BASE_URL)\(endpoints)")!
        components.queryItems = queryItems
        
        return try await doUrlRequest(componentsUrl: components.url!, dataClass: GameDetailRes.self)
    }
}
