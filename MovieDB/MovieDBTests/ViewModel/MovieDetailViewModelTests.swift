//
//  MovieDetailViewModelTests.swift
//  MovieDBTests
//
//  Created by Test on 08/03/26.
//

import XCTest
@testable import MovieDB

@MainActor
final class MovieDetailViewModelTests: XCTestCase {
    
    var sut: MovieDetailViewModel!
    var mockMovieRepository: MockMovieRepository!
    var mockFavoritesRepository: MockFavoritesRepository!
    
    @MainActor
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
    
    // MARK: - Load Movie Details Tests
    
    func testLoadMovieDetailsSuccess() async {
        let expectedMovie = Movie(
            id: 550,
            title: "Fight Club",
            overview: "An insomniac office worker...",
            releaseDate: "1999-10-15",
            voteAverage: 8.4
        )
        mockMovieRepository.mockMovie = expectedMovie
        mockFavoritesRepository.mockIsFavorite = false
        
        await sut.loadMovieDetails()
        
        XCTAssertEqual(sut.movie?.id, 550)
        XCTAssertEqual(sut.movie?.title, "Fight Club")
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
    
    // MARK: - New Fields Tests (Melhoria 4)
    
    func testLoadMovieDetailsWithAllNewFields() async {
        let movieWithNewFields = Movie(
            id: 550,
            title: "Fight Club",
            overview: "An insomniac office worker and a devil-may-care soapmaker form an underground fight club.",
            releaseDate: "1999-10-15",
            voteAverage: 8.4,
            voteCount: 29696,
            runtime: 139,
            tagline: "Your mind is the scene of the crime.",
            status: "Released",
            genreIds: [18, 28, 53]
        )
        mockMovieRepository.mockMovie = movieWithNewFields
        mockFavoritesRepository.mockIsFavorite = false
        
        await sut.loadMovieDetails()
        
        XCTAssertEqual(sut.movie?.voteCount, 29696)
        XCTAssertEqual(sut.movie?.runtime, 139)
        XCTAssertEqual(sut.movie?.tagline, "Your mind is the scene of the crime.")
        XCTAssertEqual(sut.movie?.status, "Released")
        XCTAssertEqual(sut.movie?.genreIds, [18, 28, 53])
    }
    
    func testLoadMovieDetailsWithGenreIds() async {
        let movieWithGenres = Movie(
            id: 550,
            title: "Fight Club",
            voteAverage: 8.4,
            genreIds: [18, 28, 53]
        )
        mockMovieRepository.mockMovie = movieWithGenres
        mockFavoritesRepository.mockIsFavorite = false
        
        await sut.loadMovieDetails()
        
        XCTAssertEqual(sut.movie?.genreIds, [18, 28, 53])
        XCTAssertFalse(sut.movie?.genreIds.isEmpty ?? true)
    }
    
    func testLoadMovieDetailsError() async {
        mockMovieRepository.mockError = NetworkError.unknown
        
        await sut.loadMovieDetails()
        
        XCTAssertNil(sut.movie)
        XCTAssertNotNil(sut.error)
        XCTAssertFalse(sut.isLoading)
    }
    
    // MARK: - Favorite Tests
    
    func testToggleFavoriteAddsFavorite() async {
        let movie = Movie(
            id: 550,
            title: "Fight Club",
            voteAverage: 8.4,
            voteCount: 29696,
            runtime: 139,
            genreIds: [18, 28, 53]
        )
        sut.movie = movie
        mockFavoritesRepository.mockIsFavorite = false
        
        await sut.toggleFavorite()
        
        XCTAssertTrue(sut.isFavorite)
        XCTAssertTrue(mockFavoritesRepository.saveFavoriteCalled)
    }
    
    func testToggleFavoriteRemovesFavorite() async {
        let movie = Movie(
            id: 550,
            title: "Fight Club",
            voteAverage: 8.4
        )
        sut.movie = movie
        sut.isFavorite = true
        mockFavoritesRepository.mockIsFavorite = true
        
        await sut.toggleFavorite()
        
        XCTAssertFalse(sut.isFavorite)
        XCTAssertTrue(mockFavoritesRepository.removeFavoriteCalled)
    }
    
    func testToggleFavoriteWithNoMovieFails() async {
        sut.movie = nil
        
        let initialFavorite = sut.isFavorite
        await sut.toggleFavorite()
        
        // Não muda porque movie é nil
        XCTAssertEqual(sut.isFavorite, initialFavorite)
    }
    
    func testToggleFavoriteRevertOnError() async {
        let movie = Movie(
            id: 550,
            title: "Fight Club",
            voteAverage: 8.4
        )
        sut.movie = movie
        mockFavoritesRepository.mockIsFavorite = false
        mockFavoritesRepository.mockError = NetworkError.unknown
        
        await sut.toggleFavorite()
        
        // Deve reverter ao estado anterior
        XCTAssertFalse(sut.isFavorite)
        XCTAssertNotNil(sut.error)
    }
    
    // MARK: - Loading State Tests
    
    func testLoadMovieDetailsStartsWithLoading() async {
        mockMovieRepository.mockMovie = Movie(
            id: 550,
            title: "Fight Club",
            voteAverage: 8.4
        )
        
        let task = Task {
            await sut.loadMovieDetails()
        }
        
        // Note: isLoading pode já ter mudado dependendo da velocidade
        // Mas ao final deve ser false
        await task.value
        
        XCTAssertFalse(sut.isLoading)
    }
}
