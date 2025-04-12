//
//  RemoteDataSource.swift
//  Game
//
//  Created by Zahra Nurul Izza on 11/04/25.
//

import Foundation
import Core
@preconcurrency import RxSwift
import Alamofire

public struct GameRequestType: Decodable{
    let query: String
    let genreId: String?
    let searchQuery: String?
    let page: Int?
}

public struct GameRemoteDataSource: RemoteDataSource {
    public typealias Request = GameRequestType
    public typealias Response = GamesRes

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

    public init() { }

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

    private func request<T: Decodable & Sendable>(url: String) -> Observable<T> {
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

    public func execute(req: GameRequestType) -> Observable<GamesRes> {
        var parameters: [String: String] = [
            "page": "\(req.page ?? 1)"
            ]

        if let searchQuery = req.searchQuery {
            parameters["search"] = searchQuery
        }

        if req.query == "released" {
            parameters["ordering"] = "-released"
        } else if req.query != "lucky" {
            parameters["ordering"] = req.query
        }

        if let genreId = req.genreId {
            parameters["genres"] = genreId
        }

        let url = buildUrl(endpoint: "/games", parameters: parameters)
        return request(url: url)
    }
}
