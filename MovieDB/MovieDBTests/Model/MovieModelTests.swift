//
//  MovieModelTests.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 07/03/26.
//

import XCTest
@testable import MovieDB

final class MovieModelTests: XCTestCase {
    
    // MARK: - Initialization Tests
    func testMovieInitialization() {
        // Arrange & Act
        let movie = Movie(
            id: 550,
            title: "Fight Club",
            overview: "An insomniac office worker...",
            posterPath: "/path.jpg",
            backdropPath: "/backdrop.jpg",
            releaseDate: "1999-10-15",
            voteAverage: 8.4,
            genreIds: [18, 53]
        )
        
        // Assert
        XCTAssertEqual(movie.id, 550)
        XCTAssertEqual(movie.title, "Fight Club")
        XCTAssertEqual(movie.overview, "An insomniac office worker...")
        XCTAssertEqual(movie.posterPath, "/path.jpg")
        XCTAssertEqual(movie.backdropPath, "/backdrop.jpg")
        XCTAssertEqual(movie.releaseDate, "1999-10-15")
        XCTAssertEqual(movie.voteAverage, 8.4)
        XCTAssertEqual(movie.genreIds, [18, 53])
    }
    
    func testMovieInitializationWithDefaults() {
        // Arrange & Act
        let movie = Movie(
            id: 1,
            title: "Test",
            voteAverage: 7.0
        )
        
        // Assert
        XCTAssertEqual(movie.id, 1)
        XCTAssertNil(movie.overview)
        XCTAssertNil(movie.posterPath)
        XCTAssertNil(movie.backdropPath)
        XCTAssertNil(movie.releaseDate)
        XCTAssertTrue(movie.genreIds.isEmpty)
    }
    
    // MARK: - Poster URL Tests
    func testPosterURLWithValidPath() {
        // Arrange
        let movie = Movie(
            id: 1,
            title: "Test",
            overview: nil,
            posterPath: "/abc123.jpg",
            backdropPath: nil,
            releaseDate: nil,
            voteAverage: 8.0
        )
        
        // Act & Assert
        XCTAssertNotNil(movie.posterURL)
        XCTAssertTrue(movie.posterURL?.absoluteString.contains("/abc123.jpg") ?? false)
    }
    
    func testPosterURLWithNilPath() {
        // Arrange
        let movie = Movie(
            id: 1,
            title: "Test",
            overview: nil,
            posterPath: nil,
            backdropPath: nil,
            releaseDate: nil,
            voteAverage: 8.0
        )
        
        // Act & Assert
        XCTAssertNil(movie.posterURL)
    }
    
    // MARK: - Backdrop URL Tests
    func testBackdropURLWithValidPath() {
        // Arrange
        let movie = Movie(
            id: 1,
            title: "Test",
            overview: nil,
            posterPath: nil,
            backdropPath: "/xyz789.jpg",
            releaseDate: nil,
            voteAverage: 8.0
        )
        
        // Act & Assert
        XCTAssertNotNil(movie.backdropURL)
        XCTAssertTrue(movie.backdropURL?.absoluteString.contains("/xyz789.jpg") ?? false)
    }
    
    func testBackdropURLWithNilPath() {
        // Arrange
        let movie = Movie(
            id: 1,
            title: "Test",
            overview: nil,
            posterPath: nil,
            backdropPath: nil,
            releaseDate: nil,
            voteAverage: 8.0
        )
        
        // Act & Assert
        XCTAssertNil(movie.backdropURL)
    }
    
    // MARK: - Decodable Tests
    func testMovieDecodingSuccess() throws {
        // Arrange
        let json = """
        {
            "id": 550,
            "title": "Fight Club",
            "overview": "An insomniac office worker",
            "poster_path": "/poster.jpg",
            "backdrop_path": "/backdrop.jpg",
            "release_date": "1999-10-15",
            "vote_average": 8.4,
            "genre_ids": [18, 53]
        }
        """.data(using: .utf8)!
        
        // Act
        let decoder = JSONDecoder()
        let movie = try decoder.decode(Movie.self, from: json)
        
        // Assert
        XCTAssertEqual(movie.id, 550)
        XCTAssertEqual(movie.title, "Fight Club")
        XCTAssertEqual(movie.posterPath, "/poster.jpg")
        XCTAssertEqual(movie.genreIds.count, 2)
    }
    
    func testMovieDecodingWithMissingOptionalFields() throws {
        // Arrange
        let json = """
        {
            "id": 1,
            "title": "Test Movie",
            "vote_average": 7.5
        }
        """.data(using: .utf8)!
        
        // Act
        let decoder = JSONDecoder()
        let movie = try decoder.decode(Movie.self, from: json)
        
        // Assert
        XCTAssertEqual(movie.id, 1)
        XCTAssertEqual(movie.title, "Test Movie")
        XCTAssertNil(movie.overview)
        XCTAssertNil(movie.posterPath)
        XCTAssertTrue(movie.genreIds.isEmpty)
    }
    
    func testMovieDecodingWithMissingVoteAverage() throws {
        // Arrange
        let json = """
        {
            "id": 1,
            "title": "Test Movie"
        }
        """.data(using: .utf8)!
        
        // Act
        let decoder = JSONDecoder()
        let movie = try decoder.decode(Movie.self, from: json)
        
        // Assert
        XCTAssertEqual(movie.id, 1)
        XCTAssertEqual(movie.voteAverage, 0.0) // Default value
    }
    
    func testMovieDecodingWithEmptyGenreIds() throws {
        // Arrange
        let json = """
        {
            "id": 1,
            "title": "Test",
            "vote_average": 7.0
        }
        """.data(using: .utf8)!
        
        // Act
        let decoder = JSONDecoder()
        let movie = try decoder.decode(Movie.self, from: json)
        
        // Assert
        XCTAssertTrue(movie.genreIds.isEmpty)
    }
    
    // MARK: - Identifiable Tests
    func testMovieIsIdentifiable() {
        // Arrange & Act
        let movie = Movie(id: 550, title: "Test", voteAverage: 8.0)
        
        // Assert
        XCTAssertEqual(movie.id, 550)
    }
    
    // MARK: - Codable Tests
    func testMovieEncodingDecoding() throws {
        // Arrange
        let original = Movie(
            id: 1,
            title: "Test",
            overview: "Overview",
            posterPath: "/path.jpg",
            backdropPath: "/backdrop.jpg",
            releaseDate: "2024-01-01",
            voteAverage: 8.0,
            genreIds: [18]
        )
        
        // Act
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Movie.self, from: encoded)
        
        // Assert
        XCTAssertEqual(original.id, decoded.id)
        XCTAssertEqual(original.title, decoded.title)
        XCTAssertEqual(original.voteAverage, decoded.voteAverage)
    }
}
