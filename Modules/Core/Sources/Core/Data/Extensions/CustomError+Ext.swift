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
    case notFound
    public var errorDescription: String? {
        switch self {
        case .invalidInstance: return "Database can't instance."
        case .requestFailed: return "Your request failed."
        case .notFound: return "Data not found in Database"
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
