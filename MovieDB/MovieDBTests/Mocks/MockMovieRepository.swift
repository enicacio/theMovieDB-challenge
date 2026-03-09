//
//  MockMovieRepository.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 07/03/26.
//

@testable import MovieDB

final class MockMovieRepository: MovieRepositoryProtocol {
    var mockMovies: [Movie] = []
    var mockGenres: [Genre] = []
    var mockMovieDetail: Movie?
    var mockError: NetworkError?
    
    func fetchPopularMovies(page: Int) async throws -> [Movie] {
        if let error = mockError { throw error }
        return mockMovies
    }
    
    func searchMovies(query: String, page: Int) async throws -> [Movie] {
        if let error = mockError { throw error }
        return mockMovies.filter { $0.title.contains(query) }
    }
    
    func fetchGenres() async throws -> [Genre] {
        if let error = mockError { throw error }
        return mockGenres
    }
    
    func fetchMovieDetails(id: Int) async throws -> Movie {
        if let error = mockError { throw error }
        return mockMovieDetail ?? mockMovies.first ?? Movie(id: id, title: "", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 0)
    }
}
