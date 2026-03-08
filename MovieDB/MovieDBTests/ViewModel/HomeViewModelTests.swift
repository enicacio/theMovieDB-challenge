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
        await sut.loadPopularMovies()  // Carrega página 1
        
        // Assert initial state
        XCTAssertEqual(sut.currentPage, 1)
        
        // Arrange page 2
        let page2Movies = [
            Movie(id: 2, title: "Movie 2", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 7.5)
        ]
        mockMovieRepository.mockMovies = page2Movies
        
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
        await sut.loadPopularMovies()
        
        XCTAssertEqual(sut.movies.count, 1)
        
        // Arrange - Page 2
        let page2Movies = [
            Movie(id: 2, title: "Movie 2", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 7.5),
            Movie(id: 3, title: "Movie 3", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 7.0)
        ]
        mockMovieRepository.mockMovies = page2Movies
        
        // Act
        await sut.loadMoreMovies()
        
        // Assert - Should have 3 movies total (1 from page 1 + 2 from page 2)
        XCTAssertEqual(sut.movies.count, 3)
        XCTAssertEqual(sut.movies[0].id, 1)  // First is from page 1
        XCTAssertEqual(sut.movies[1].id, 2)  // Then page 2
        XCTAssertEqual(sut.movies[2].id, 3)
    }

    func testLoadMoreMoviesMultiplePagesSuccessively() async {
        // Arrange - Page 1
        let page1 = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
        ]
        mockMovieRepository.mockMovies = page1
        await sut.loadPopularMovies()
        
        // Act & Assert - Page 2
        let page2 = [
            Movie(id: 2, title: "Movie 2", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 7.5)
        ]
        mockMovieRepository.mockMovies = page2
        await sut.loadMoreMovies()
        
        XCTAssertEqual(sut.currentPage, 2)
        XCTAssertEqual(sut.movies.count, 2)
        
        // Act & Assert - Page 3
        let page3 = [
            Movie(id: 3, title: "Movie 3", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 7.0)
        ]
        mockMovieRepository.mockMovies = page3
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
        await sut.loadPopularMovies()
        
        let initialPage = sut.currentPage
        let initialCount = sut.movies.count
        
        // Arrange - Network error
        mockMovieRepository.mockError = .networkUnavailable
        
        // Act
        await sut.loadMoreMovies()
        
        // Assert - Page should not increment on error
        XCTAssertEqual(sut.currentPage, initialPage)
        XCTAssertEqual(sut.movies.count, initialCount)  // Filmes não mudam
        XCTAssertNotNil(sut.error)
        XCTAssertEqual(sut.error?.message, "Erro ao carregar mais filmes")
    }

    func testLoadMoreMoviesHandlesTimeoutError() async {
        // Arrange
        let page1Movies = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
        ]
        mockMovieRepository.mockMovies = page1Movies
        await sut.loadPopularMovies()
        
        let initialPage = sut.currentPage
        mockMovieRepository.mockError = .timedOut
        
        // Act
        await sut.loadMoreMovies()
        
        // Assert
        XCTAssertEqual(sut.currentPage, initialPage)
        XCTAssertNotNil(sut.error)
    }


    func testLoadMoreMoviesHandlesServerError() async {
        // Arrange
        let page1Movies = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
        ]
        mockMovieRepository.mockMovies = page1Movies
        await sut.loadPopularMovies()
        
        let initialPage = sut.currentPage
        mockMovieRepository.mockError = .serverError(statusCode: 500)
        
        // Act
        await sut.loadMoreMovies()
        
        // Assert
        XCTAssertEqual(sut.currentPage, initialPage)
        XCTAssertNotNil(sut.error)
    }
    
    func testLoadMoreMoviesDecrementsPageOnError() async {
        // Arrange
        let page1Movies = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
        ]
        mockMovieRepository.mockMovies = page1Movies
        await sut.loadPopularMovies()
        
        XCTAssertEqual(sut.currentPage, 1)
        
        mockMovieRepository.mockError = .networkUnavailable
        
        // Act
        await sut.loadMoreMovies()
        
        // Assert - Deve voltar à página 1 após erro
        XCTAssertEqual(sut.currentPage, 1)
    }

    func testLoadMoreMoviesSetsIsLoadingMoreFlag() async {
        // Arrange
        let movies = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
        ]
        mockMovieRepository.mockMovies = movies
        await sut.loadPopularMovies()
        
        // Assert initial state
        XCTAssertFalse(sut.isLoadingMore)
        
        // Act & Assert
        mockMovieRepository.mockMovies = []
        await sut.loadMoreMovies()
        
        // Assert after loading
        XCTAssertFalse(sut.isLoadingMore)  // Deve ser false após completar
    }

    func testLoadMoreMoviesEmptyPageStopsLoading() async {
        // Arrange - Load first page
        let page1Movies = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
        ]
        mockMovieRepository.mockMovies = page1Movies
        await sut.loadPopularMovies()
        
        // Arrange - Empty page (último resultado da API)
        mockMovieRepository.mockMovies = []
        
        // Act
        await sut.loadMoreMovies()
        
        // Assert - Deve manter página mas não adicionar filmes
        XCTAssertEqual(sut.currentPage, 2)
        XCTAssertEqual(sut.movies.count, 1)  // Apenas o primeiro filme
        XCTAssertNil(sut.error)
    }

    func testLoadMoreMoviesPreservesExistingData() async {
        // Arrange - Load page 1 with specific data
        let page1Movies = [
            Movie(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: "/1.jpg",
                  backdropPath: "/back1.jpg", releaseDate: "2024-01-01", voteAverage: 8.0),
            Movie(id: 2, title: "Movie 2", overview: "Overview 2", posterPath: "/2.jpg",
                  backdropPath: "/back2.jpg", releaseDate: "2024-02-01", voteAverage: 7.5)
        ]
        mockMovieRepository.mockMovies = page1Movies
        await sut.loadPopularMovies()
        
        // Arrange - Page 2
        let page2Movies = [
            Movie(id: 3, title: "Movie 3", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 7.0)
        ]
        mockMovieRepository.mockMovies = page2Movies
        
        // Act
        await sut.loadMoreMovies()
        
        // Assert - Original data should be preserved
        XCTAssertEqual(sut.movies[0].title, "Movie 1")
        XCTAssertEqual(sut.movies[0].overview, "Overview 1")
        XCTAssertEqual(sut.movies[1].title, "Movie 2")
        XCTAssertEqual(sut.movies[2].title, "Movie 3")
    }

    func testLoadMoreMoviesClearsErrorOnSuccess() async {
        // Arrange - Cause an error first
        mockMovieRepository.mockError = .networkUnavailable
        await sut.loadPopularMovies()
        XCTAssertNotNil(sut.error)
        
        // Reset repository
        mockMovieRepository.mockError = nil
        let movies = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
        ]
        mockMovieRepository.mockMovies = movies
        
        // Act - Try load popular again
        await sut.loadPopularMovies()
        
        // Assert - Error should be cleared
        XCTAssertNil(sut.error)
    }

    func testLoadMoreMoviesCalledConsecutively() async {
        // Arrange - Load page 1
        let page1 = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
        ]
        mockMovieRepository.mockMovies = page1
        await sut.loadPopularMovies()
        
        // Act - Load page 2
        let page2 = [
            Movie(id: 2, title: "Movie 2", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 7.5)
        ]
        mockMovieRepository.mockMovies = page2
        await sut.loadMoreMovies()
        
        let page2Count = sut.movies.count
        
        // Act - Load page 3 immediately
        let page3 = [
            Movie(id: 3, title: "Movie 3", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 7.0)
        ]
        mockMovieRepository.mockMovies = page3
        await sut.loadMoreMovies()
        
        // Assert - Should have all movies from all pages
        XCTAssertEqual(sut.movies.count, 3)
        XCTAssertEqual(sut.currentPage, 3)
    }

    func testLoadMoreMoviesWithLargePageSize() async {
        // Arrange - Load page 1 with many movies
        var page1Movies: [Movie] = []
        for i in 1...20 {
            page1Movies.append(
                Movie(id: i, title: "Movie \(i)", overview: nil, posterPath: nil,
                      backdropPath: nil, releaseDate: nil, voteAverage: Double(8.0 - Double(i) * 0.1))
            )
        }
        mockMovieRepository.mockMovies = page1Movies
        await sut.loadPopularMovies()
        
        // Arrange - Page 2 with more movies
        var page2Movies: [Movie] = []
        for i in 21...40 {
            page2Movies.append(
                Movie(id: i, title: "Movie \(i)", overview: nil, posterPath: nil,
                      backdropPath: nil, releaseDate: nil, voteAverage: Double(8.0 - Double(i) * 0.1))
            )
        }
        mockMovieRepository.mockMovies = page2Movies
        
        // Act
        await sut.loadMoreMovies()
        
        // Assert
        XCTAssertEqual(sut.movies.count, 40)
        XCTAssertEqual(sut.currentPage, 2)
        XCTAssertEqual(sut.movies.first?.id, 1)
        XCTAssertEqual(sut.movies.last?.id, 40)
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
        await sut.loadPopularMovies()
        
        sut.minRating = 7.0
        
        XCTAssertEqual(sut.filteredMovies.count, 1)
        XCTAssertEqual(sut.filteredMovies.first?.title, "High Rating")
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
        await sut.loadPopularMovies()
        
        let page2Movies = [
            Movie(id: 2, title: "Movie 2", overview: nil, posterPath: nil,
                  backdropPath: nil, releaseDate: nil, voteAverage: 6.0)
        ]
        mockMovieRepository.mockMovies = page2Movies
        await sut.loadMoreMovies()
        
        sut.minRating = 7.5
        
        XCTAssertEqual(sut.movies.count, 2)
        XCTAssertEqual(sut.filteredMovies.count, 1)
        XCTAssertEqual(sut.filteredMovies.first?.id, 1)
    }
}
