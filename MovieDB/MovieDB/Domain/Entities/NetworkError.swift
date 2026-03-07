//
//  NetworkError.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 06/03/26.
//

import Foundation

enum NetworkError: LocalizedError, Identifiable, Equatable {
    case invalidURL
    case networkUnavailable
    case timedOut
    case unauthorized
    case forbidden
    case notFound
    case serverError(statusCode: Int)
    case decodingError(details: String? = nil)
    case unknown
    
    var id: String {
        String(describing: self)
    }
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid request URL"
        case .networkUnavailable:
            return "Network is unavailable. Please check your internet connection."
        case .timedOut:
            return "Request timed out. Please try again."
        case .unauthorized:
            return "Unauthorized. Please login again."
        case .forbidden:
            return "Access forbidden."
        case .notFound:
            return "Resource not found."
        case .serverError(let code):
            return "Server error (\(code)). Please try again later."
        case .decodingError(let details):
            return "Failed to parse response.\(details.map { " \($0)" } ?? "")"
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
    
    var isRetryable: Bool {
        switch self {
        case .networkUnavailable, .timedOut, .serverError:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Equatable
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.networkUnavailable, .networkUnavailable),
             (.timedOut, .timedOut),
             (.unauthorized, .unauthorized),
             (.forbidden, .forbidden),
             (.notFound, .notFound),
             (.unknown, .unknown):
            return true
        case (.serverError(let lhsCode), .serverError(let rhsCode)):
            return lhsCode == rhsCode
        case (.decodingError, .decodingError):
            return true
        default:
            return false
        }
    }
}
