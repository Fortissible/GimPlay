//
//  CustomError+Ext.swift
//  Core
//
//  Created by Zahra Nurul Izza on 11/04/25.
//
import Foundation

public enum URLError: LocalizedError {
    case invalidResponse
    case addressUnreachable(URL)
    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response"
        case .addressUnreachable(let url):
            return "Address unreachable for \(url.absoluteString)"
        }
    }
}

public enum DatabaseError: LocalizedError {
    case invalidInstance
    case requestFailed
    public var errorDescription: String? {
        switch self {
        case .invalidInstance:
            return "Invalid instance"
        case .requestFailed:
            return "Request failed"
        }
    }
}

public enum NetworkError: Error, LocalizedError {
    case connectionFailed
    case decodingError
    public var errorDescription: String? {
        switch self {
        case .connectionFailed:
            return "Network connection error. Please check your network connections and try again"
        case .decodingError:
            return "Failed to decode the response. Please check the API Response structure"
        }
    }
}
