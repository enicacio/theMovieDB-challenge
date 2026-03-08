//
//  HomeViewModelTests.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 07/03/26.
//

import XCTest
@testable import MovieDB

@MainActor
final class HomeViewModelTests: XCTestCase {
    var sut: HomeViewModel!
    var mockMovieRepository: MockMovieRepository!
    var mockFavoritesRepository: MockFavoritesRepository!
    
    override func setUp() {
        super.setUp()
        mockMovieRepository = MockMovieRepository()
        mockFavoritesRepository = MockFavoritesRepository()
        sut = HomeViewModel(
            movieRepository: mockMovieRepository,
            favoritesRepository: mockFavoritesRepository
        )
    }
    
    override func tearDown() {
        sut = nil
        mockMovieRepository = nil
        mockFavoritesRepository = nil
        super.tearDown()
    }
    
    // MARK: - Load Popular Movies Tests
    func testLoadPopularMoviesSuccess() async {
        // Arrange
        let mockMovies = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 8.0),
            Movie(id: 2, title: "Movie 2", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 7.5)
        ]
        mockMovieRepository.mockMovies = mockMovies
        
        // Act
        await sut.loadPopularMovies()
        
        // Assert
        XCTAssertEqual(sut.movies.count, 2)
        XCTAssertNil(sut.error)
    }
    
    func testLoadPopularMoviesEmpty() async {
        // Arrange
        mockMovieRepository.mockMovies = []
        
        // Act
        await sut.loadPopularMovies()
        
        // Assert
        XCTAssertTrue(sut.movies.isEmpty)
    }
    
    func testLoadPopularMoviesServerError() async {
        // Arrange
        mockMovieRepository.mockError = .serverError(statusCode: 500)
        
        // Act
        await sut.loadPopularMovies()
        
        // Assert
        XCTAssertTrue(sut.movies.isEmpty)
        XCTAssertNotNil(sut.error)
    }
    
    func testLoadPopularMoviesTimeout() async {
        // Arrange
        mockMovieRepository.mockError = .timedOut
        
        // Act
        await sut.loadPopularMovies()
        
        // Assert
        XCTAssertNotNil(sut.error)
        XCTAssertTrue(sut.movies.isEmpty)
    }
    
    func testLoadPopularMoviesNetworkError() async {
        // Arrange
        mockMovieRepository.mockError = .networkUnavailable
        
        // Act
        await sut.loadPopularMovies()
        
        // Assert
        XCTAssertNotNil(sut.error)
    }
    
    func testErrorMessageNotNilOnFailure() async {
        // Arrange
        mockMovieRepository.mockError = .networkUnavailable
        
        // Act
        await sut.loadPopularMovies()
        
        // Assert
        XCTAssertNotNil(sut.error)
        XCTAssertNotNil(sut.error?.message)
    }
    
    // MARK: - Favorite Toggle Tests
    func testToggleFavoriteSuccess() async {
        // Arrange
        let movie = Movie(id: 1, title: "Test", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
        
        // Act
        await sut.toggleFavorite(movie: movie)
        
        // Assert
        XCTAssertTrue(mockFavoritesRepository.savedIds.contains(1))
    }
    
    func testToggleFavoriteTwice() async {
        // Arrange
        let movie = Movie(id: 1, title: "Test", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
        
        // Act
        await sut.toggleFavorite(movie: movie)
        let afterFirstToggle = mockFavoritesRepository.savedIds.contains(1)
        
        await sut.toggleFavorite(movie: movie)
        let afterSecondToggle = mockFavoritesRepository.savedIds.contains(1)
        
        // Assert
        XCTAssertTrue(afterFirstToggle)
        XCTAssertFalse(afterSecondToggle)
    }
    
    func testToggleMultipleFavorites() async {
        // Arrange
        let movie1 = Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
        let movie2 = Movie(id: 2, title: "Movie 2", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 7.5)
        
        // Act
        await sut.toggleFavorite(movie: movie1)
        await sut.toggleFavorite(movie: movie2)
        
        // Assert
        XCTAssertTrue(mockFavoritesRepository.savedIds.contains(1))
        XCTAssertTrue(mockFavoritesRepository.savedIds.contains(2))
    }
    
    // MARK: - Search Text State Tests
    func testSearchTextUpdate() {
        // Arrange
        let newText = "Avatar"
        
        // Act
        sut.searchText = newText
        
        // Assert
        XCTAssertEqual(sut.searchText, "Avatar")
    }
    
    func testSearchTextClear() {
        // Arrange
        sut.searchText = "Avatar"
        
        // Act
        sut.searchText = ""
        
        // Assert
        XCTAssertEqual(sut.searchText, "")
    }
    
    func testSearchTextMultipleUpdates() {
        // Act
        sut.searchText = "Avatar"
        XCTAssertEqual(sut.searchText, "Avatar")
        
        sut.searchText = "Inception"
        XCTAssertEqual(sut.searchText, "Inception")
        
        sut.searchText = ""
        XCTAssertEqual(sut.searchText, "")
    }
    
    // MARK: - Loading State Tests
    func testIsLoadingInitialState() {
        // Assert
        XCTAssertFalse(sut.isLoading)
    }
    
    func testErrorInitialState() {
        // Assert
        XCTAssertNil(sut.error)
    }
    
    func testMoviesInitialState() {
        // Assert
        XCTAssertTrue(sut.movies.isEmpty)
    }
    
    // MARK: - Multiple Load Calls
    func testLoadPopularMoviesMultipleCalls() async {
        // Arrange - First call
        let movies1 = [Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 8.0)]
        mockMovieRepository.mockMovies = movies1
        
        // Act
        await sut.loadPopularMovies()
        let firstLoadCount = sut.movies.count
        
        // Arrange - Second call with different data
        let movies2 = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 8.0),
            Movie(id: 2, title: "Movie 2", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 7.5)
        ]
        mockMovieRepository.mockMovies = movies2
        
        // Act
        await sut.loadPopularMovies()
        let secondLoadCount = sut.movies.count
        
        // Assert
        XCTAssertEqual(firstLoadCount, 1)
        XCTAssertEqual(secondLoadCount, 2)
    }
    
    // MARK: - Error Recovery
    func testRecoverFromErrorOnNextLoad() async {
        // Arrange - First call with error
        mockMovieRepository.mockError = .networkUnavailable
        
        // Act
        await sut.loadPopularMovies()
        XCTAssertNotNil(sut.error)
        
        // Arrange - Second call without error
        mockMovieRepository.mockError = nil
        mockMovieRepository.mockMovies = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
        ]
        sut.error = nil
        
        // Act
        await sut.loadPopularMovies()
        
        // Assert
        XCTAssertNil(sut.error)
        XCTAssertEqual(sut.movies.count, 1)
    }
    
    // MARK: - Empty Search State Tests
    func testSearchMoviesEmptyResultShowsEmptyState() async {
        // Arrange
        sut.searchText = "nonexistent"  // ← NOVO: Define o texto
        mockMovieRepository.mockMovies = []
        
        // Act
        await sut.searchMovies(query: "nonexistent")
        
        // Assert
        XCTAssertTrue(sut.movies.isEmpty)
        XCTAssertFalse(sut.searchText.isEmpty)
        XCTAssertEqual(sut.searchText, "nonexistent")
    }
    
    func testClearSearchButtonResetsState() {
        // Arrange
        sut.searchText = "Avatar"
        XCTAssertFalse(sut.searchText.isEmpty)
        
        // Act
        sut.searchText = ""
        
        // Assert
        XCTAssertTrue(sut.searchText.isEmpty)
    }

    
    func testClearSearchLoadPopularMovies() async {
        // Arrange
        let movies = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
        ]
        mockMovieRepository.mockMovies = movies
        
        // Act - Simula clicar no "x" da SearchBar
        await sut.loadPopularMovies()
        
        // Assert
        XCTAssertEqual(sut.movies.count, 1)
        XCTAssertTrue(sut.searchText.isEmpty)
    }

    func testSearchTextChangeOnlySearchesWhenNotEmpty() async {
        // Arrange
        let initialMovies = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
        ]
        mockMovieRepository.mockMovies = initialMovies
        await sut.loadPopularMovies()
        
        // Act - Simula apagar o texto (searchText vira "")
        sut.searchText = ""
        
        XCTAssertTrue(sut.searchText.isEmpty)
    }

    func testSearchTextChangeSearchesWhenNotEmpty() async {
        // Arrange
        let searchResults = [
            Movie(id: 2, title: "Avatar", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 7.8)
        ]
        mockMovieRepository.mockMovies = searchResults
        
        // Act
        sut.searchText = "Avatar"
        await sut.searchMovies(query: "Avatar")
        
        // Assert
        XCTAssertEqual(sut.movies.count, 1)
        XCTAssertEqual(sut.movies.first?.title, "Avatar")
    }
}
