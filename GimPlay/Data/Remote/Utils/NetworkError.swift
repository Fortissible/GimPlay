//
//  NetworkError.swift
//  GimPlay
//
//  Created by Wildan on 14/03/25.
//

import Foundation

enum NetworkError : Error {
    case connectionFailed
    case decodingError
}

extension NetworkError : LocalizedError {
    var errorDescription: String? {
        switch self {
            case .connectionFailed:
                return "Network connection error. Please check your network connections and try again"
            case .decodingError:
                return "Failed to decode the response. Please check the API Response structure"
        }
    }
}
