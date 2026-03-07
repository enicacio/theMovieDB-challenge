//
//  MovieRepositoryTests.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 07/03/26.
//

import XCTest
@testable import MovieDB

@MainActor
final class MovieRepositoryTests: XCTestCase {
    var sut: MovieRepository!
    var mockAPIService: MockAPIService!
    
    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()
        sut = MovieRepository(apiService: mockAPIService)
    }
    
    override func tearDown() {
        sut = nil
        mockAPIService = nil
        super.tearDown()
    }
    
    // MARK: - fetchPopularMovies Tests
    func testFetchPopularMoviesSuccess() async {
        // Arrange
        let mockResponse = MovieResponse(
            results: [
                Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
            ],
            page: 1,
            totalPages: 100,
            totalResults: 1000
        )
        mockAPIService.mockResponse = mockResponse
        
        // Act
        let result = try? await sut.fetchPopularMovies(page: 1)
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 1)
        XCTAssertEqual(result?.first?.id, 1)
    }
    
    func testFetchPopularMoviesError() async {
        // Arrange
        mockAPIService.mockError = .networkUnavailable
        
        // Act & Assert
        do {
            _ = try await sut.fetchPopularMovies(page: 1)
            XCTFail("Should have thrown error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .networkUnavailable)
        } catch {
            XCTFail("Wrong error type")
        }
    }
    
    func testFetchPopularMoviesMultiplePages() async {
        // Arrange
        let mockResponse = MovieResponse(
            results: [
                Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 8.0),
                Movie(id: 2, title: "Movie 2", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 7.5)
            ],
            page: 2,
            totalPages: 100,
            totalResults: 2000
        )
        mockAPIService.mockResponse = mockResponse
        
        // Act
        let result = try? await sut.fetchPopularMovies(page: 2)
        
        // Assert
        XCTAssertEqual(result?.count, 2)
    }
    
    // MARK: - searchMovies Tests
    func testSearchMoviesSuccess() async {
        // Arrange
        let mockResponse = MovieResponse(
            results: [
                Movie(id: 550, title: "Fight Club", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 8.4)
            ],
            page: 1,
            totalPages: 10,
            totalResults: 100
        )
        mockAPIService.mockResponse = mockResponse
        
        // Act
        let result = try? await sut.searchMovies(query: "fight", page: 1)
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 1)
        XCTAssertEqual(result?.first?.title, "Fight Club")
    }
    
    func testSearchMoviesEmpty() async {
        // Arrange
        let mockResponse = MovieResponse(
            results: [],
            page: 1,
            totalPages: 0,
            totalResults: 0
        )
        mockAPIService.mockResponse = mockResponse
        
        // Act
        let result = try? await sut.searchMovies(query: "nonexistent", page: 1)
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.isEmpty ?? false)
    }
    
    func testSearchMoviesError() async {
        // Arrange
        mockAPIService.mockError = .timedOut
        
        // Act & Assert
        do {
            _ = try await sut.searchMovies(query: "test", page: 1)
            XCTFail("Should have thrown error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .timedOut)
        } catch {
            XCTFail("Wrong error type")
        }
    }
    
    // MARK: - fetchGenres Tests
    func testFetchGenresSuccess() async {
        // Arrange
        let mockResponse = GenreResponse(
            genres: [
                Genre(id: 18, name: "Drama"),
                Genre(id: 28, name: "Action")
            ]
        )
        mockAPIService.mockResponse = mockResponse
        
        // Act
        let result = try? await sut.fetchGenres()
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 2)
        XCTAssertEqual(result?.first?.name, "Drama")
    }
    
    func testFetchGenresError() async {
        // Arrange
        mockAPIService.mockError = .serverError(statusCode: 500)
        
        // Act & Assert
        do {
            _ = try await sut.fetchGenres()
            XCTFail("Should have thrown error")
        } catch let error as NetworkError {
            if case .serverError(let code) = error {
                XCTAssertEqual(code, 500)
            } else {
                XCTFail("Wrong error type")
            }
        } catch {
            XCTFail("Wrong error type")
        }
    }
    
    // MARK: - fetchMovieDetails Tests
    func testFetchMovieDetailsSuccess() async {
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
        mockAPIService.mockResponse = mockMovie
        
        // Act
        let result = try? await sut.fetchMovieDetails(id: 550)
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, 550)
        XCTAssertEqual(result?.title, "Fight Club")
        XCTAssertEqual(result?.genreIds.count, 2)
    }
    
    func testFetchMovieDetailsError() async {
        // Arrange
        mockAPIService.mockError = .notFound
        
        // Act & Assert
        do {
            _ = try await sut.fetchMovieDetails(id: 999)
            XCTFail("Should have thrown error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .notFound)
        } catch {
            XCTFail("Wrong error type")
        }
    }
}
