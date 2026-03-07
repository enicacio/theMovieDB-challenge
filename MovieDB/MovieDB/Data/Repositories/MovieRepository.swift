//
//  MovieRepository.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 07/03/26.
//

import Foundation

final class MovieRepository: MovieRepositoryProtocol {
    // MARK: - Properties
    private let apiService: APIServiceProtocol
    
    // MARK: - Initialization
    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }
    
    // MARK: - MovieRepositoryProtocol
    func fetchPopularMovies(page: Int) async throws -> [Movie] {
        let response: MovieResponse = try await apiService.request(
            endpoint: .popularMovies(page: page)
        )
        return response.results
    }
    
    func searchMovies(query: String, page: Int) async throws -> [Movie] {
        let response: MovieResponse = try await apiService.request(
            endpoint: .searchMovies(query: query, page: page)
        )
        return response.results
    }
    
    func fetchGenres() async throws -> [Genre] {
        let response: GenreResponse = try await apiService.request(
            endpoint: .genres
        )
        return response.genres
    }
    
    func fetchMovieDetails(id: Int) async throws -> Movie {
        let movie: Movie = try await apiService.request(
            endpoint: .movieDetails(id: id)
        )
        return movie
    }
}
