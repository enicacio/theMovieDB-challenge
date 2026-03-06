//
//  Movie.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 06/03/26.
//

import Foundation

struct Movie: Codable, Identifiable {
    
    // MARK: - Properties
    let id: Int
    let title: String
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double
    var genreIds: [Int] = []
    
    // MARK: - Computed Properties
    
    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: Configuration.imageBaseURL + posterPath)
    }
    
    var backdropURL: URL? {
        guard let backdropPath = backdropPath else { return nil }
        return URL(string: Configuration.imageBaseURL + backdropPath)
    }
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case genreIds = "genre_ids"
    }
}
