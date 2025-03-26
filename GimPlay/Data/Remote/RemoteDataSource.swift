//
//  RemoteDataSource.swift
//  GimPlay
//
//  Created by Wildan on 07/03/25.
//

import Foundation
import Alamofire
import RxSwift

protocol IRemoteDataSource {
    func getGamesFromApi(query: String, genreId: String?, searchQuery: String?) -> Observable<GamesRes>
    func getGenresFromApi() -> Observable<GenreRes>
    func getGameDetailFromApi(id: String) -> Observable<GameDetailRes>
}

class RemoteDataSource: IRemoteDataSource {
    private let API_KEYS = "INSERT_API_TOKEN_HERE"
    private let BASE_URL = "https://api.rawg.io/api"
    
    private init() { }
    
    static let sharedInstance: RemoteDataSource = RemoteDataSource()
}

extension RemoteDataSource {
    private var defaultQueryItems: [String: String] {
        return [
            "key": API_KEYS,
            "page_size": "10",
            "page": "1"
        ]
    }
    
    private func buildUrl(endpoint: String, parameters: [String: String]?) -> String {
        var allParams = defaultQueryItems
        parameters?.forEach { allParams[$0.key] = $0.value }
        
        let queryString = allParams.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        return "\(BASE_URL)\(endpoint)?\(queryString)"
    }
    
    private func request<T: Decodable>(url: String) -> Observable<T> {
        return Observable.create { observer in
            let request = AF.request(url)
                .validate()
                .responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let data):
                        observer.onNext(data)
                        observer.onCompleted()
                    case .failure:
                        observer.onError(NetworkError.connectionFailed)
                    }
                }
            
            return Disposables.create { request.cancel() }
        }
    }
    
    func getGamesFromApi(query: String, genreId: String?, searchQuery: String?) -> Observable<GamesRes> {
        var parameters: [String: String] = [:]
        
        if let searchQuery = searchQuery {
            parameters["search"] = searchQuery
        }
        
        if query == "released" {
            parameters["ordering"] = "-released"
        } else if query != "lucky" {
            parameters["ordering"] = query
        }
        
        if let genreId = genreId {
            parameters["genres"] = genreId
        }
        
        let url = buildUrl(endpoint: "/games", parameters: parameters)
        return request(url: url)
    }
    
    func getGenresFromApi() -> Observable<GenreRes> {
        let url = buildUrl(endpoint: "/genres", parameters: nil)
        return request(url: url)
    }
    
    func getGameDetailFromApi(id: String) -> Observable<GameDetailRes> {
        let url = buildUrl(endpoint: "/games/\(id)", parameters: nil)
        return request(url: url)
    }
}
