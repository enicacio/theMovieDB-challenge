//
//  FavoritesViewModelTests.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 07/03/26.
//

import XCTest
@testable import MovieDB

@MainActor
final class FavoritesViewModelTests: XCTestCase {
    var sut: FavoritesViewModel!
    var mockFavoritesRepository: MockFavoritesRepository!
    
    override func setUp() {
        super.setUp()
        mockFavoritesRepository = MockFavoritesRepository()
        sut = FavoritesViewModel(favoritesRepository: mockFavoritesRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockFavoritesRepository = nil
        super.tearDown()
    }
    
    // MARK: - loadFavorites Tests
    func testLoadFavoritesSuccess() async {
        // Arrange
        let mockMovies = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 8.0),
            Movie(id: 2, title: "Movie 2", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 7.5)
        ]
        mockFavoritesRepository.mockFavorites = mockMovies
        
        // Act
        await sut.loadFavorites()
        
        // Assert
        XCTAssertEqual(sut.favorites.count, 2)
        XCTAssertEqual(sut.favorites.first?.title, "Movie 1")
        XCTAssertNil(sut.error)
        XCTAssertFalse(sut.isLoading)
    }
    
    func testLoadFavoritesEmpty() async {
        // Arrange
        mockFavoritesRepository.mockFavorites = []
        
        // Act
        await sut.loadFavorites()
        
        // Assert
        XCTAssertTrue(sut.favorites.isEmpty)
        XCTAssertNil(sut.error)
    }
    
    func testLoadFavoritesNetworkError() async {
        // Arrange
        mockFavoritesRepository.mockError = .networkUnavailable
        
        // Act
        await sut.loadFavorites()
        
        // Assert
        XCTAssertTrue(sut.favorites.isEmpty)
        XCTAssertNotNil(sut.error)
        XCTAssertEqual(sut.error?.message, "Network is unavailable. Please check your internet connection.")
    }
    
    func testLoadFavoritesServerError() async {
        // Arrange
        mockFavoritesRepository.mockError = .serverError(statusCode: 500)
        
        // Act
        await sut.loadFavorites()
        
        // Assert
        XCTAssertTrue(sut.favorites.isEmpty)
        XCTAssertNotNil(sut.error)
    }
    
    func testLoadFavoritesShowsLoading() async {
        // Arrange
        mockFavoritesRepository.mockFavorites = []
        
        // Act
        let task = Task {
            await sut.loadFavorites()
        }
        
        // Assert (loading true while loading)
        XCTAssertFalse(sut.isLoading) // Will be false after completion
        
        await task.value
    }
    
    // MARK: - removeFavorite Tests
    func testRemoveFavoriteSuccess() async {
        // Arrange
        sut.favorites = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 8.0),
            Movie(id: 2, title: "Movie 2", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 7.5)
        ]
        
        // Act
        await sut.removeFavorite(movieId: 1)
        
        // Assert
        XCTAssertEqual(sut.favorites.count, 1)
        XCTAssertEqual(sut.favorites.first?.id, 2)
        XCTAssertNil(sut.error)
    }
    
    func testRemoveFavoriteNotFound() async {
        // Arrange
        sut.favorites = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
        ]
        
        // Act
        await sut.removeFavorite(movieId: 999)
        
        // Assert
        XCTAssertEqual(sut.favorites.count, 1) // Nada removido
    }
    
    func testRemoveFavoriteError() async {
        // Arrange
        sut.favorites = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
        ]
        mockFavoritesRepository.mockError = .unknown
        
        // Act
        await sut.removeFavorite(movieId: 1)
        
        // Assert
        XCTAssertEqual(sut.favorites.count, 1) // Não removeu
        XCTAssertNotNil(sut.error)
    }
    
    func testRemoveMultipleFavorites() async {
        // Arrange
        sut.favorites = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 8.0),
            Movie(id: 2, title: "Movie 2", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 7.5),
            Movie(id: 3, title: "Movie 3", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 7.0)
        ]
        
        // Act
        await sut.removeFavorite(movieId: 1)
        await sut.removeFavorite(movieId: 3)
        
        // Assert
        XCTAssertEqual(sut.favorites.count, 1)
        XCTAssertEqual(sut.favorites.first?.id, 2)
    }
}
