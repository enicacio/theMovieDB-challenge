//
//  APIEndpoint.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 06/03/26.
//

import Foundation

enum APIEndpoint {
    
    // MARK: - Cases
    
    case popularMovies(page: Int)
    case searchMovies(query: String, page: Int)
    case genres
    case movieDetails(id: Int)
    
    // MARK: - Path
    
    var path: String {
        switch self {
        case .popularMovies:
            return "/movie/popular"
        case .searchMovies:
            return "/search/movie"
        case .genres:
            return "/genre/movie/list"
        case .movieDetails(let id):
            return "/movie/\(id)"
        }
    }
    
    // MARK: - Query Items
    
    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = [
            URLQueryItem(name: "api_key", value: Configuration.apiKey),
            URLQueryItem(name: "language", value: "en-US")
        ]
        
        switch self {
        case .popularMovies(let page):
            items.append(URLQueryItem(name: "page", value: String(page)))
        case .searchMovies(let query, let page):
            items.append(URLQueryItem(name: "query", value: query))
            items.append(URLQueryItem(name: "page", value: String(page)))
        default:
            break
        }
        return items
    }
}
