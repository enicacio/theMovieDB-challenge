//
//  MockMovieRepository.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 07/03/26.
//

@testable import MovieDB

final class MockMovieRepository: MovieRepositoryProtocol {
    var mockMovies: [Movie] = []
    var mockMovie: Movie?
    var mockGenres: [Genre] = []
    var mockError: NetworkError?
    
    func fetchPopularMovies(page: Int) async throws -> [Movie] {
        if let error = mockError {
            throw error
        }
        return mockMovies
    }

    
    func searchMovies(query: String, page: Int) async throws -> [Movie] {
        if let error = mockError {
            throw error
        }
        return mockMovies
    }
    
    func fetchGenres() async throws -> [Genre] {
        if let error = mockError {
            throw error
        }
        return mockGenres
    }
    
    func fetchMovieDetails(id: Int) async throws -> Movie {
        if let error = mockError {
            throw error
        }
        return mockMovie ?? Movie(id: id, title: "Test", voteAverage: 0)
    }
}
