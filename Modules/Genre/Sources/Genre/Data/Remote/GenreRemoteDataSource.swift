//
//  Untitled.swift
//  Genre
//
//  Created by Zahra Nurul Izza on 12/04/25.
//
import Core
import Foundation
import Alamofire
@preconcurrency import RxSwift

public struct GenreRemoteDataSource: RemoteDataSource {
    public typealias Request = Any
    public typealias Response = GenreRes

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

    public func execute(req: Any) -> Observable<GenreRes> {
        let url = buildUrl(endpoint: "/genres", parameters: nil)
        return request(url: url)
    }
}
