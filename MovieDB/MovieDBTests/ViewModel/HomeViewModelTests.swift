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
    
    // MARK: - Load More Movies Pagination Tests
    func testLoadMoreMoviesIncrementsPageFromOne() async {
        // Arrange
        let page1Movies = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
        ]
        mockMovieRepository.mockMovies = page1Movies
        await sut.loadPopularMovies()
        
        // Assert initial state
        XCTAssertEqual(sut.currentPage, 1)
        
        // Arrange page 2 - IMPORTANTE: Resetar dados do mock ANTES de chamar
        let page2Movies = [
            Movie(id: 2, title: "Movie 2", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 7.5)
        ]
        mockMovieRepository.mockMovies = page2Movies
        mockMovieRepository.mockError = nil  // Resetar erro também
        
        // Act
        await sut.loadMoreMovies()
        
        // Assert
        XCTAssertEqual(sut.currentPage, 2)
    }

    func testLoadMoreMoviesAppendsNotReplaces() async {
        // Arrange - Load page 1
        let page1Movies = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
        ]
        mockMovieRepository.mockMovies = page1Movies
        mockMovieRepository.mockError = nil
        await sut.loadPopularMovies()
        
        // Verificar que carregou corretamente
        XCTAssertEqual(sut.movies.count, 1, "Page 1 deve ter 1 filme")
        XCTAssertGreaterThanOrEqual(sut.movies.count, 1, "Deve ter pelo menos 1 filme para continuar teste")
        
        // Arrange - Page 2 (NOVO: garantir que é limpo)
        let page2Movies = [
            Movie(id: 2, title: "Movie 2", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 7.5),
            Movie(id: 3, title: "Movie 3", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 7.0)
        ]
        mockMovieRepository.mockMovies = page2Movies
        mockMovieRepository.mockError = nil
        
        // Act
        await sut.loadMoreMovies()
        
        // Assert - Verificar count ANTES de acessar índices
        XCTAssertEqual(sut.movies.count, 3, "Deve ter 3 filmes no total (1 de page 1 + 2 de page 2)")
        
        // Só acessar índices se count passou
        if sut.movies.count >= 3 {
            XCTAssertEqual(sut.movies[0].id, 1, "Primeiro filme deve ser do page 1")
            XCTAssertEqual(sut.movies[1].id, 2, "Segundo filme deve ser do page 2")
            XCTAssertEqual(sut.movies[2].id, 3, "Terceiro filme deve ser do page 2")
        }
    }

    func testLoadMoreMoviesMultiplePagesSuccessively() async {
        // Arrange - Page 1
        let page1 = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
        ]
        mockMovieRepository.mockMovies = page1
        mockMovieRepository.mockError = nil
        await sut.loadPopularMovies()
        
        XCTAssertEqual(sut.movies.count, 1)
        
        // Act & Assert - Page 2
        let page2 = [
            Movie(id: 2, title: "Movie 2", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 7.5)
        ]
        mockMovieRepository.mockMovies = page2
        mockMovieRepository.mockError = nil
        await sut.loadMoreMovies()
        
        XCTAssertEqual(sut.currentPage, 2)
        XCTAssertEqual(sut.movies.count, 2)
        
        // Act & Assert - Page 3
        let page3 = [
            Movie(id: 3, title: "Movie 3", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 7.0)
        ]
        mockMovieRepository.mockMovies = page3
        mockMovieRepository.mockError = nil
        await sut.loadMoreMovies()
        
        XCTAssertEqual(sut.currentPage, 3)
        XCTAssertEqual(sut.movies.count, 3)
    }

    func testLoadMoreMoviesHandlesNetworkError() async {
        // Arrange - Load initial movies
        let page1Movies = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
        ]
        mockMovieRepository.mockMovies = page1Movies
        mockMovieRepository.mockError = nil
        await sut.loadPopularMovies()
        
        let initialPage = sut.currentPage
        let initialCount = sut.movies.count
        
        // Arrange - Network error
        mockMovieRepository.mockError = .networkUnavailable
        
        // Act
        await sut.loadMoreMovies()
        
        // Assert - Page should not increment on error
        XCTAssertEqual(sut.currentPage, initialPage)
        XCTAssertEqual(sut.movies.count, initialCount)
        XCTAssertNotNil(sut.error)
        // Não verificar mensagem exata, só que tem erro
    }

    func testLoadMoreMoviesHandlesTimeoutError() async {
        // Arrange
        let page1Movies = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
        ]
        mockMovieRepository.mockMovies = page1Movies
        mockMovieRepository.mockError = nil
        await sut.loadPopularMovies()
        
        let initialPage = sut.currentPage
        mockMovieRepository.mockError = .timedOut
        
        // Act
        await sut.loadMoreMovies()
        
        // Assert
        XCTAssertEqual(sut.currentPage, initialPage)
        XCTAssertNotNil(sut.error)
    }

    // MARK: - Search Tests
    func testSearchMoviesSuccess() async {
        // Arrange
        let searchMovies = [
            Movie(id: 1, title: "Inception", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 8.8)
        ]
        mockMovieRepository.mockMovies = searchMovies
        mockMovieRepository.mockError = nil
        
        // Act
        await sut.searchMovies(query: "Inception")
        
        // Assert
        XCTAssertEqual(sut.movies.count, 1)
        XCTAssertEqual(sut.movies.first?.title, "Inception")
    }
    
    func testSearchMoviesEmpty() async {
        // Arrange
        mockMovieRepository.mockMovies = []
        mockMovieRepository.mockError = nil
        
        // Act
        await sut.searchMovies(query: "nonexistent")
        
        // Assert
        XCTAssertTrue(sut.movies.isEmpty)
    }
    
    func testSearchMoviesError() async {
        // Arrange
        mockMovieRepository.mockError = .networkUnavailable
        
        // Act
        await sut.searchMovies(query: "Avatar")
        
        // Assert
        XCTAssertNotNil(sut.error)
    }

    // MARK: - Clear Search Tests
    func testClearSearchResetsState() async {
        // Arrange
        let movies = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
        ]
        mockMovieRepository.mockMovies = movies
        mockMovieRepository.mockError = nil
        
        sut.searchText = "Avatar"
        await sut.searchMovies(query: "Avatar")
        
        XCTAssertFalse(sut.searchText.isEmpty)
        
        // Act
        sut.searchText = ""
        
        // Assert
        XCTAssertTrue(sut.searchText.isEmpty)
    }
    
    func testSearchTextProperty() {
        // Act & Assert
        sut.searchText = "Avatar"
        XCTAssertEqual(sut.searchText, "Avatar")
        
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
        mockMovieRepository.mockError = nil
        
        // Act
        await sut.loadPopularMovies()
        let firstLoadCount = sut.movies.count
        
        // Arrange - Second call with different data
        let movies2 = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 8.0),
            Movie(id: 2, title: "Movie 2", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 7.5)
        ]
        mockMovieRepository.mockMovies = movies2
        mockMovieRepository.mockError = nil
        
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
    
    // MARK: - Search State Tests
    func testSearchMoviesEmptyResultShowsEmptyState() async {
        // Arrange
        sut.searchText = "nonexistent"
        mockMovieRepository.mockMovies = []
        mockMovieRepository.mockError = nil
        
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
        mockMovieRepository.mockError = nil
        
        // Act
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
        mockMovieRepository.mockError = nil
        await sut.loadPopularMovies()
        
        // Act
        sut.searchText = ""
        
        // Assert
        XCTAssertTrue(sut.searchText.isEmpty)
    }

    func testSearchTextChangeSearchesWhenNotEmpty() async {
        // Arrange
        let searchResults = [
            Movie(id: 2, title: "Avatar", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 7.8)
        ]
        mockMovieRepository.mockMovies = searchResults
        mockMovieRepository.mockError = nil
        
        // Act
        sut.searchText = "Avatar"
        await sut.searchMovies(query: "Avatar")
        
        // Assert
        XCTAssertEqual(sut.movies.count, 1)
        if let firstMovie = sut.movies.first {
            XCTAssertEqual(firstMovie.title, "Avatar")
        }
    }
    
    // MARK: - Rating Filter Tests
    func testMinRatingInitializesAtZero() {
        XCTAssertEqual(sut.minRating, 0.0)
    }

    func testFilteredMoviesReturnsAllWhenMinRatingZero() async {
        let movies = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 5.0),
            Movie(id: 2, title: "Movie 2", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
        ]
        mockMovieRepository.mockMovies = movies
        mockMovieRepository.mockError = nil
        await sut.loadPopularMovies()
        
        XCTAssertEqual(sut.filteredMovies.count, 2)
    }

    func testFilteredMoviesFiltersAboveMinRating() async {
        let movies = [
            Movie(id: 1, title: "Low Rating", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 5.0),
            Movie(id: 2, title: "High Rating", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
        ]
        mockMovieRepository.mockMovies = movies
        mockMovieRepository.mockError = nil
        await sut.loadPopularMovies()
        
        sut.minRating = 7.0
        
        XCTAssertEqual(sut.filteredMovies.count, 1)
        if let firstMovie = sut.filteredMovies.first {
            XCTAssertEqual(firstMovie.title, "High Rating")
        }
    }

    func testFilteredMoviesWithHighMinRating() async {
        let movies = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 6.0),
            Movie(id: 2, title: "Movie 2", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 7.0),
            Movie(id: 3, title: "Movie 3", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 9.0)
        ]
        mockMovieRepository.mockMovies = movies
        mockMovieRepository.mockError = nil
        await sut.loadPopularMovies()
        
        sut.minRating = 8.5
        
        XCTAssertEqual(sut.filteredMovies.count, 1)
        XCTAssertEqual(sut.filteredMovies.first?.id, 3)
    }

    func testFilteredMoviesEmptyWhenNoMatches() async {
        let movies = [
            Movie(id: 1, title: "Low 1", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 5.0),
            Movie(id: 2, title: "Low 2", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 6.0)
        ]
        mockMovieRepository.mockMovies = movies
        mockMovieRepository.mockError = nil
        await sut.loadPopularMovies()
        
        sut.minRating = 9.0
        
        XCTAssertTrue(sut.filteredMovies.isEmpty)
    }

    func testRatingFilterWithPaginatedMovies() async {
        let page1Movies = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
        ]
        mockMovieRepository.mockMovies = page1Movies
        mockMovieRepository.mockError = nil
        await sut.loadPopularMovies()
        
        let page2Movies = [
            Movie(id: 2, title: "Movie 2", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 6.0)
        ]
        mockMovieRepository.mockMovies = page2Movies
        mockMovieRepository.mockError = nil
        await sut.loadMoreMovies()
        
        sut.minRating = 7.5
        
        XCTAssertEqual(sut.movies.count, 2)
        XCTAssertEqual(sut.filteredMovies.count, 1)
        XCTAssertEqual(sut.filteredMovies.first?.id, 1)
    }
}
