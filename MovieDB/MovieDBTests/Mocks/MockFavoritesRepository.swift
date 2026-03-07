//
//  MockFavoritesRepository.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 07/03/26.
//

@testable import MovieDB

final class MockFavoritesRepository: FavoritesRepositoryProtocol {
    var savedIds: Set<Int> = []
    var mockFavorites: [Movie] = []
    var mockError: NetworkError?
    
    func saveFavorite(_ movie: Movie) async throws {
        if let error = mockError { throw error }
        savedIds.insert(movie.id)
    }
    
    func removeFavorite(movieId: Int) async throws {
        if let error = mockError { throw error }
        savedIds.remove(movieId)
    }
    
    func fetchFavorites() async throws -> [Movie] {
        if let error = mockError { throw error }
        return mockFavorites
    }
    
    func isFavorite(movieId: Int) async throws -> Bool {
        if let error = mockError { throw error }
        return savedIds.contains(movieId)
    }
}
