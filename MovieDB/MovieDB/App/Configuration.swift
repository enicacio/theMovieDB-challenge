//
//  Configuration.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 03/03/26.
//

import Foundation

struct Configuration {
    
    // MARK: - API Configuration
    static let apiKey = "API_KEY"
    static let baseURL = "https://api.themoviedb.org/3"
    static let imageBaseURL = "https://image.tmdb.org/t/p/w500"
    
    // MARK: - App Configuration
    static let appName = "MovieDB"
    static let appVersion = "1.0.0"
    
    // MARK: - Network Configuration
    static let requestTimeout: TimeInterval = 30
    static let defaultPageSize = 20
}
