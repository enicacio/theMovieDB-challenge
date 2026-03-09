//
//  MockFavoritesRepository.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 07/03/26.
//

@testable import MovieDB

final class MockFavoritesRepository: FavoritesRepositoryProtocol {
    var savedIds: Set<Int> = []
    var mockIsFavorite = false
    var mockFavorites: [Movie] = []
    var mockError: NetworkError?
    var saveFavoriteCalled = false
    var removeFavoriteCalled = false
    
    func isFavorite(movieId: Int) async throws -> Bool {
        if let error = mockError {
            throw error
        }
        return mockIsFavorite
    }
    
    func saveFavorite(_ movie: Movie) async throws {
        if let error = mockError {
            throw error
        }
        saveFavoriteCalled = true
        mockIsFavorite = true
        mockFavorites.append(movie)
    }
    
    func removeFavorite(movieId: Int) async throws {
        if let error = mockError {
            throw error
        }
        removeFavoriteCalled = true
        mockIsFavorite = false
        mockFavorites.removeAll(where: { $0.id == movieId })
    }
    
    func fetchFavorites() async throws -> [Movie] {
        if let error = mockError {
            throw error
        }
        return mockFavorites
    }
}
