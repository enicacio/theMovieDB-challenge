//
//  APIResponseTests.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 07/03/26.
//

import XCTest
@testable import MovieDB

final class APIResponseTests: XCTestCase {
    
    // MARK: - MovieResponse Initialization
    func testMovieResponseInitialization() {
        // Arrange
        let movies = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
        ]
        
        // Act
        let response = MovieResponse(
            results: movies,
            page: 1,
            totalPages: 100,
            totalResults: 1000
        )
        
        // Assert
        XCTAssertEqual(response.results.count, 1)
        XCTAssertEqual(response.page, 1)
        XCTAssertEqual(response.totalPages, 100)
        XCTAssertEqual(response.totalResults, 1000)
    }
    
    func testMovieResponseWithEmptyResults() {
        // Arrange & Act
        let response = MovieResponse(
            results: [],
            page: 1,
            totalPages: 0,
            totalResults: 0
        )
        
        // Assert
        XCTAssertTrue(response.results.isEmpty)
        XCTAssertEqual(response.totalResults, 0)
    }
    
    func testMovieResponseWithMultipleMovies() {
        // Arrange
        let movies = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 8.0),
            Movie(id: 2, title: "Movie 2", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 7.5),
            Movie(id: 3, title: "Movie 3", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 7.0)
        ]
        
        // Act
        let response = MovieResponse(
            results: movies,
            page: 1,
            totalPages: 50,
            totalResults: 1500
        )
        
        // Assert
        XCTAssertEqual(response.results.count, 3)
        XCTAssertEqual(response.totalResults, 1500)
    }
    
    // MARK: - MovieResponse Decodable
    func testMovieResponseDecodingSuccess() throws {
        // Arrange
        let json = """
        {
            "results": [
                {
                    "id": 550,
                    "title": "Fight Club",
                    "vote_average": 8.4
                }
            ],
            "page": 1,
            "total_pages": 100,
            "total_results": 1000
        }
        """.data(using: .utf8)!
        
        // Act
        let decoder = JSONDecoder()
        let response = try decoder.decode(MovieResponse.self, from: json)
        
        // Assert
        XCTAssertEqual(response.results.count, 1)
        XCTAssertEqual(response.page, 1)
        XCTAssertEqual(response.totalPages, 100)
    }
    
    func testMovieResponseDecodingWithMissingOptionalFields() throws {
        // Arrange
        let json = """
        {
            "results": [
                {
                    "id": 1,
                    "title": "Test",
                    "vote_average": 7.0
                }
            ],
            "page": 1,
            "total_pages": 10,
            "total_results": 100
        }
        """.data(using: .utf8)!
        
        // Act
        let decoder = JSONDecoder()
        let response = try decoder.decode(MovieResponse.self, from: json)
        
        // Assert
        XCTAssertEqual(response.results.count, 1)
        XCTAssertNil(response.results[0].overview)
        XCTAssertNil(response.results[0].posterPath)
    }
    
    // MARK: - GenreResponse Initialization
    func testGenreResponseInitialization() {
        // Arrange
        let genres = [
            Genre(id: 18, name: "Drama"),
            Genre(id: 28, name: "Action")
        ]
        
        // Act
        let response = GenreResponse(genres: genres)
        
        // Assert
        XCTAssertEqual(response.genres.count, 2)
        XCTAssertEqual(response.genres.first?.name, "Drama")
    }
    
    func testGenreResponseWithEmptyGenres() {
        // Arrange & Act
        let response = GenreResponse(genres: [])
        
        // Assert
        XCTAssertTrue(response.genres.isEmpty)
    }
    
    func testGenreResponseWithMultipleGenres() {
        // Arrange
        let genres = [
            Genre(id: 18, name: "Drama"),
            Genre(id: 28, name: "Action"),
            Genre(id: 35, name: "Comedy"),
            Genre(id: 53, name: "Thriller")
        ]
        
        // Act
        let response = GenreResponse(genres: genres)
        
        // Assert
        XCTAssertEqual(response.genres.count, 4)
    }
    
    // MARK: - GenreResponse Decodable
    func testGenreResponseDecodingSuccess() throws {
        // Arrange
        let json = """
        {
            "genres": [
                {"id": 18, "name": "Drama"},
                {"id": 28, "name": "Action"}
            ]
        }
        """.data(using: .utf8)!
        
        // Act
        let decoder = JSONDecoder()
        let response = try decoder.decode(GenreResponse.self, from: json)
        
        // Assert
        XCTAssertEqual(response.genres.count, 2)
        XCTAssertEqual(response.genres[0].name, "Drama")
        XCTAssertEqual(response.genres[1].name, "Action")
    }
    
    func testGenreResponseDecodingWithEmptyArray() throws {
        // Arrange
        let json = """
        {
            "genres": []
        }
        """.data(using: .utf8)!
        
        // Act
        let decoder = JSONDecoder()
        let response = try decoder.decode(GenreResponse.self, from: json)
        
        // Assert
        XCTAssertTrue(response.genres.isEmpty)
    }
    
    // MARK: - Codable Tests
    func testMovieResponseEncodingDecoding() throws {
        // Arrange
        let original = MovieResponse(
            results: [Movie(id: 1, title: "Test", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 8.0)],
            page: 1,
            totalPages: 10,
            totalResults: 100
        )
        
        // Act
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(MovieResponse.self, from: encoded)
        
        // Assert
        XCTAssertEqual(original.page, decoded.page)
        XCTAssertEqual(original.totalPages, decoded.totalPages)
        XCTAssertEqual(original.results.count, decoded.results.count)
    }
    
    func testGenreResponseEncodingDecoding() throws {
        // Arrange
        let original = GenreResponse(genres: [
            Genre(id: 18, name: "Drama"),
            Genre(id: 28, name: "Action")
        ])
        
        // Act
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(GenreResponse.self, from: encoded)
        
        // Assert
        XCTAssertEqual(original.genres.count, decoded.genres.count)
        XCTAssertEqual(original.genres[0].name, decoded.genres[0].name)
    }
}
