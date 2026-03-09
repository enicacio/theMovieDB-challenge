//
//  MovieDetailViewModelTests.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 07/03/26.
//

import XCTest
@testable import MovieDB

@MainActor
final class MovieDetailViewModelTests: XCTestCase {
    var sut: MovieDetailViewModel!
    var mockMovieRepository: MockMovieRepository!
    var mockFavoritesRepository: MockFavoritesRepository!
    
    override func setUp() {
        super.setUp()
        mockMovieRepository = MockMovieRepository()
        mockFavoritesRepository = MockFavoritesRepository()
        sut = MovieDetailViewModel(
            movieId: 550,
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
    
    // MARK: - loadMovieDetails Tests
    func testLoadMovieDetailsSuccess() async {
        // Arrange
        let mockMovie = Movie(
            id: 550,
            title: "Fight Club",
            overview: "An insomniac office worker...",
            posterPath: "/path.jpg",
            backdropPath: "/backdrop.jpg",
            releaseDate: "1999-10-15",
            voteAverage: 8.4,
            genreIds: [18, 53]
        )
        mockMovieRepository.mockMovieDetail = mockMovie
        mockFavoritesRepository.mockFavorites = []
        
        // Act
        await sut.loadMovieDetails()
        
        // Assert
        XCTAssertEqual(sut.movie?.id, 550)
        XCTAssertEqual(sut.movie?.title, "Fight Club")
        XCTAssertFalse(sut.isFavorite)
        XCTAssertNil(sut.error)
    }
    
    func testLoadMovieDetailsNetworkError() async {
        // Arrange
        mockMovieRepository.mockError = .networkUnavailable
        
        // Act
        await sut.loadMovieDetails()
        
        // Assert
        XCTAssertNil(sut.movie)
        XCTAssertNotNil(sut.error)
        XCTAssertEqual(sut.error?.message, "Network is unavailable. Please check your internet connection.")
    }
    
    func testLoadMovieDetailsServerError() async {
        // Arrange
        mockMovieRepository.mockError = .serverError(statusCode: 500)
        
        // Act
        await sut.loadMovieDetails()
        
        // Assert
        XCTAssertNil(sut.movie)
        XCTAssertNotNil(sut.error)
    }
    
    func testLoadMovieDetailsChecksFavoriteStatus() async {
        // Arrange
        let mockMovie = Movie(
            id: 550,
            title: "Fight Club",
            overview: nil,
            posterPath: nil,
            backdropPath: nil,
            releaseDate: nil,
            voteAverage: 8.0
        )
        mockMovieRepository.mockMovieDetail = mockMovie
        mockFavoritesRepository.savedIds = [550]
        
        // Act
        await sut.loadMovieDetails()
        
        // Assert
        XCTAssertTrue(sut.isFavorite)
    }
    
    // MARK: - loadGenres Tests
    func testLoadGenresSuccess() async {
        // Arrange
        mockMovieRepository.mockGenres = [
            Genre(id: 18, name: "Drama"),
            Genre(id: 53, name: "Thriller")
        ]
        sut.movie = Movie(
            id: 550,
            title: "Fight Club",
            overview: nil,
            posterPath: nil,
            backdropPath: nil,
            releaseDate: nil,
            voteAverage: 8.4,
            genreIds: [18, 53]
        )
        
        // Act
        await sut.loadGenres()
        
        // Assert
        XCTAssertEqual(sut.genres.count, 2)
        XCTAssertEqual(sut.genreNames.count, 2)
        XCTAssertTrue(sut.genreNames.contains("Drama"))
        XCTAssertTrue(sut.genreNames.contains("Thriller"))
    }
    
    func testLoadGenresError() async {
        // Arrange
        mockMovieRepository.mockError = .networkUnavailable
        
        // Act
        await sut.loadGenres()
        
        // Assert
        XCTAssertTrue(sut.genres.isEmpty)
        XCTAssertNotNil(sut.error)
    }
    
    func testGenreNamesWhenMovieIsNil() {
        // Arrange
        sut.movie = nil
        mockMovieRepository.mockGenres = [Genre(id: 18, name: "Drama")]
        
        // Assert
        XCTAssertTrue(sut.genreNames.isEmpty)
    }
    
    func testGenreNamesFiltersCorrectly() {
        // Arrange
        sut.movie = Movie(
            id: 1,
            title: "Test",
            overview: nil,
            posterPath: nil,
            backdropPath: nil,
            releaseDate: nil,
            voteAverage: 8.0,
            genreIds: [18]
        )
        mockMovieRepository.mockGenres = [
            Genre(id: 18, name: "Drama"),
            Genre(id: 53, name: "Thriller"),
            Genre(id: 28, name: "Action")
        ]
        sut.genres = mockMovieRepository.mockGenres
        
        // Assert
        XCTAssertEqual(sut.genreNames.count, 1)
        XCTAssertEqual(sut.genreNames.first, "Drama")
    }
    
    // MARK: - toggleFavorite Tests
    func testToggleFavoriteFromUnfavorited() async {
        // Arrange
        let movie = Movie(
            id: 550,
            title: "Test",
            overview: nil,
            posterPath: nil,
            backdropPath: nil,
            releaseDate: nil,
            voteAverage: 8.0
        )
        sut.movie = movie
        sut.isFavorite = false
        
        // Act
        await sut.toggleFavorite()
        
        // Assert
        XCTAssertTrue(sut.isFavorite)
        XCTAssertTrue(mockFavoritesRepository.savedIds.contains(550))
    }
    
    func testToggleFavoriteFromFavorited() async {
        // Arrange
        let movie = Movie(
            id: 550,
            title: "Test",
            overview: nil,
            posterPath: nil,
            backdropPath: nil,
            releaseDate: nil,
            voteAverage: 8.0
        )
        sut.movie = movie
        sut.isFavorite = true
        mockFavoritesRepository.savedIds = [550]
        
        // Act
        await sut.toggleFavorite()
        
        // Assert
        XCTAssertFalse(sut.isFavorite)
        XCTAssertFalse(mockFavoritesRepository.savedIds.contains(550))
    }
    
    func testToggleFavoriteError() async {
        // Arrange
        let movie = Movie(
            id: 550,
            title: "Test",
            overview: nil,
            posterPath: nil,
            backdropPath: nil,
            releaseDate: nil,
            voteAverage: 8.0
        )
        sut.movie = movie
        sut.isFavorite = false
        mockFavoritesRepository.mockError = .unknown
        
        // Act
        await sut.toggleFavorite()
        
        // Assert
        XCTAssertFalse(sut.isFavorite) // Reverteu
        XCTAssertNotNil(sut.error)
    }
    
    func testToggleFavoriteWhenMovieIsNil() async {
        // Arrange
        sut.movie = nil
        
        // Act
        await sut.toggleFavorite()
        
        // Assert
        XCTAssertNil(sut.movie)
    }
}
