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
    func getGamesFromApi(query: String, genreId: String?, searchQuery: String?, page: Int?) -> Observable<GamesRes>
    func getGenresFromApi() -> Observable<GenreRes>
    func getGameDetailFromApi(id: String) -> Observable<GameDetailRes>
}

class RemoteDataSource: IRemoteDataSource {
    private var API_KEYS: String {
        guard let filePath = Bundle.main.path(forResource: "env", ofType: "plist") else {
            fatalError("Couldn't find file 'env.plist'.")
        }

        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "API_KEYS") as? String else {
            fatalError("Couldn't find key 'API_KEYS' in 'env.plist'.")
        }
        return value
    }
    private let BASE_URL = "https://api.rawg.io/api"

    private init() { }

    static let sharedInstance: RemoteDataSource = RemoteDataSource()
}

extension RemoteDataSource {
    private var defaultQueryItems: [String: String] {
        return [
            "key": API_KEYS,
            "page_size": "10"
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

    func getGamesFromApi(query: String, genreId: String?, searchQuery: String?, page: Int?) -> Observable<GamesRes> {
        var parameters: [String: String] = [
                "page": "\(page ?? 1)"
            ]

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
