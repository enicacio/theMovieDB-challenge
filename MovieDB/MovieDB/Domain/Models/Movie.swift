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
    var voteCount: Int = 0
    var runtime: Int = 0
    var tagline: String?
    var status: String? = nil
    var genreIds: [Int] = []
    
    // MARK: - Init Padrão (para Preview e testes)
    init(
        id: Int,
        title: String,
        overview: String? = nil,
        posterPath: String? = nil,
        backdropPath: String? = nil,
        releaseDate: String? = nil,
        voteAverage: Double,
        voteCount: Int = 0,
        runtime: Int = 0,
        tagline: String? = nil,
        status: String? = nil,
        genreIds: [Int] = []
    ) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.runtime = runtime
        self.tagline = tagline
        self.status = status
        self.genreIds = genreIds
    }
    
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
        case voteCount = "vote_count"
        case runtime
        case tagline
        case status
        case genreIds = "genre_ids"
        case genres
    }
    
    // MARK: - Decodable (para API)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.overview = try container.decodeIfPresent(String.self, forKey: .overview)
        self.posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        self.backdropPath = try container.decodeIfPresent(String.self, forKey: .backdropPath)
        self.releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        self.voteAverage = try container.decodeIfPresent(Double.self, forKey: .voteAverage) ?? 0.0
        self.voteCount = try container.decodeIfPresent(Int.self, forKey: .voteCount) ?? 0
        self.runtime = try container.decodeIfPresent(Int.self, forKey: .runtime) ?? 0
        self.tagline = try container.decodeIfPresent(String.self, forKey: .tagline)
        self.status = try container.decodeIfPresent(String.self, forKey: .status)
        
        // Tenta decodificar genre_ids (endpoints /popular, /search)
        self.genreIds = try container.decodeIfPresent([Int].self, forKey: .genreIds) ?? []
        
        // Se genre_ids vazio, extrai de genres (endpoint /movie/{id}?append_to_response=genres)
        if self.genreIds.isEmpty {
            let genres = try container.decodeIfPresent([Genre].self, forKey: .genres) ?? []
            self.genreIds = genres.map { $0.id }
        }
    }
    
    // MARK: - Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(overview, forKey: .overview)
        try container.encodeIfPresent(posterPath, forKey: .posterPath)
        try container.encodeIfPresent(backdropPath, forKey: .backdropPath)
        try container.encodeIfPresent(releaseDate, forKey: .releaseDate)
        try container.encode(voteAverage, forKey: .voteAverage)
        try container.encode(voteCount, forKey: .voteCount)
        try container.encode(runtime, forKey: .runtime)
        try container.encodeIfPresent(tagline, forKey: .tagline)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encode(genreIds, forKey: .genreIds)
    }
}
