//
//  RemoteDataSource.swift
//  GimPlay
//
//  Created by Wildan on 07/03/25.
//

import Foundation

class RemoteDataSource {
    let API_KEYS = "INSERT_YOUR_TOKEN_HERE"
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
            throw NetworkError.connectionFailed
        }
        
        let decoder = JSONDecoder()
        
//        JSONParsingChecker(classes: T.self, data: data) // USE FOR CHECK DATA JSON PARSING ERROR
        
        do {
            let result = try decoder.decode(T.self, from: data)
            return result
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func getGamesFromApi(query: String, genreId: String?, searchQuery: String?) async throws -> GamesRes {
        let endpoints = "/games"
        var components = URLComponents(string: "\(BASE_URL)\(endpoints)")!
        
        if searchQuery != nil {
            queryItems.append(URLQueryItem(name: "search", value: searchQuery))
        }
        
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
