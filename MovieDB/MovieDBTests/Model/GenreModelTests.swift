//
//  GenreModelTests.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 07/03/26.
//

import XCTest
@testable import MovieDB

final class GenreModelTests: XCTestCase {
    
    // MARK: - Initialization Tests
    func testGenreInitialization() {
        // Arrange & Act
        let genre = Genre(id: 18, name: "Drama")
        
        // Assert
        XCTAssertEqual(genre.id, 18)
        XCTAssertEqual(genre.name, "Drama")
    }
    
    func testGenreWithDifferentIDs() {
        // Arrange & Act
        let drama = Genre(id: 18, name: "Drama")
        let action = Genre(id: 28, name: "Action")
        
        // Assert
        XCTAssertNotEqual(drama.id, action.id)
        XCTAssertNotEqual(drama.name, action.name)
    }
    
    func testGenreWithEmptyName() {
        // Arrange & Act
        let genre = Genre(id: 1, name: "")
        
        // Assert
        XCTAssertEqual(genre.name, "")
    }
    
    // MARK: - Decodable Tests
    func testGenreDecodingSuccess() throws {
        // Arrange
        let json = """
        {
            "id": 18,
            "name": "Drama"
        }
        """.data(using: .utf8)!
        
        // Act
        let decoder = JSONDecoder()
        let genre = try decoder.decode(Genre.self, from: json)
        
        // Assert
        XCTAssertEqual(genre.id, 18)
        XCTAssertEqual(genre.name, "Drama")
    }
    
    func testGenreDecodingMultiple() throws {
        // Arrange
        let json = """
        [
            {"id": 18, "name": "Drama"},
            {"id": 28, "name": "Action"},
            {"id": 35, "name": "Comedy"}
        ]
        """.data(using: .utf8)!
        
        // Act
        let decoder = JSONDecoder()
        let genres = try decoder.decode([Genre].self, from: json)
        
        // Assert
        XCTAssertEqual(genres.count, 3)
        XCTAssertEqual(genres[0].name, "Drama")
        XCTAssertEqual(genres[1].name, "Action")
        XCTAssertEqual(genres[2].name, "Comedy")
    }
    
    // MARK: - Codable Tests
    func testGenreEncoding() throws {
        // Arrange
        let genre = Genre(id: 18, name: "Drama")
        
        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(genre)
        
        // Assert
        XCTAssertNotNil(data)
    }
    
    func testGenreEncodingDecoding() throws {
        // Arrange
        let original = Genre(id: 28, name: "Action")
        
        // Act
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Genre.self, from: encoded)
        
        // Assert
        XCTAssertEqual(original.id, decoded.id)
        XCTAssertEqual(original.name, decoded.name)
    }
    
    // MARK: - Equatable Tests
    func testGenreEquality() {
        // Arrange
        let genre1 = Genre(id: 18, name: "Drama")
        let genre2 = Genre(id: 18, name: "Drama")
        
        // Assert
        XCTAssertEqual(genre1, genre2)
    }
    
    func testGenreInequality() {
        // Arrange
        let drama = Genre(id: 18, name: "Drama")
        let action = Genre(id: 28, name: "Action")
        
        // Assert
        XCTAssertNotEqual(drama, action)
    }
    
    // MARK: - Common Genres
    func testDramaGenre() {
        // Arrange & Act
        let drama = Genre(id: 18, name: "Drama")
        
        // Assert
        XCTAssertEqual(drama.name, "Drama")
    }
    
    func testActionGenre() {
        // Arrange & Act
        let action = Genre(id: 28, name: "Action")
        
        // Assert
        XCTAssertEqual(action.name, "Action")
    }
    
    func testThrillerGenre() {
        // Arrange & Act
        let thriller = Genre(id: 53, name: "Thriller")
        
        // Assert
        XCTAssertEqual(thriller.name, "Thriller")
    }
}
