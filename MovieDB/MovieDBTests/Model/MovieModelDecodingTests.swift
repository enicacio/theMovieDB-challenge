//
//  MovieModelDecodingTests.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 08/03/26.
//

import XCTest
@testable import MovieDB

final class MovieModelDecodingTests: XCTestCase {
    
    let decoder = JSONDecoder()
    
    // MARK: - Genre IDs Decoding Tests (endpoints /popular, /search)
    
    func testDecodeMovieWithGenreIds() throws {
        let json = """
        {
          "id": 550,
          "title": "Fight Club",
          "genre_ids": [18, 28, 53],
          "vote_average": 8.4,
          "vote_count": 29696,
          "runtime": 139,
          "tagline": "Your mind is the scene of the crime.",
          "status": "Released"
        }
        """
        
        let movie = try decoder.decode(Movie.self, from: json.data(using: .utf8)!)
        
        XCTAssertEqual(movie.id, 550)
        XCTAssertEqual(movie.genreIds, [18, 28, 53])
        XCTAssertEqual(movie.voteCount, 29696)
        XCTAssertEqual(movie.runtime, 139)
        XCTAssertEqual(movie.tagline, "Your mind is the scene of the crime.")
    }
    
    func testDecodeMovieGenreIdsPriority() throws {
        // Se vir genre_ids, deve usar aquele, não genres
        let json = """
        {
          "id": 550,
          "title": "Fight Club",
          "genre_ids": [18, 28],
          "genres": [
            {"id": 80, "name": "Crime"},
            {"id": 53, "name": "Thriller"}
          ],
          "vote_average": 8.4
        }
        """
        
        let movie = try decoder.decode(Movie.self, from: json.data(using: .utf8)!)
        
        // genre_ids tem prioridade
        XCTAssertEqual(movie.genreIds, [18, 28])
        XCTAssertNotEqual(movie.genreIds, [80, 53])
    }
    
    // MARK: - Genres Array Decoding Tests (endpoint /movie/{id}?append_to_response)
    
    func testDecodeMovieWithGenresArray() throws {
        let json = """
        {
          "id": 550,
          "title": "Fight Club",
          "genres": [
            {"id": 18, "name": "Drama"},
            {"id": 28, "name": "Action"},
            {"id": 53, "name": "Thriller"}
          ],
          "vote_average": 8.4,
          "vote_count": 29696,
          "runtime": 139
        }
        """
        
        let movie = try decoder.decode(Movie.self, from: json.data(using: .utf8)!)
        
        // Deve extrair IDs de genres
        XCTAssertEqual(movie.genreIds, [18, 28, 53])
        XCTAssertEqual(movie.voteCount, 29696)
        XCTAssertEqual(movie.runtime, 139)
    }
    
    func testDecodeMovieWithEmptyGenresArray() throws {
        let json = """
        {
          "id": 550,
          "title": "Fight Club",
          "genres": [],
          "vote_average": 8.4
        }
        """
        
        let movie = try decoder.decode(Movie.self, from: json.data(using: .utf8)!)
        
        XCTAssertTrue(movie.genreIds.isEmpty)
    }
    
    func testDecodeMovieWithoutGenreIdsOrGenres() throws {
        let json = """
        {
          "id": 550,
          "title": "Fight Club",
          "vote_average": 8.4
        }
        """
        
        let movie = try decoder.decode(Movie.self, from: json.data(using: .utf8)!)
        
        XCTAssertTrue(movie.genreIds.isEmpty)
    }
    
    // MARK: - All New Fields Tests (Melhoria 4)
    
    func testDecodeMovieWithAllNewFields() throws {
        let json = """
        {
          "id": 550,
          "title": "Fight Club",
          "overview": "An insomniac office worker and a devil-may-care soapmaker form an underground fight club.",
          "poster_path": "/poster.jpg",
          "backdrop_path": "/backdrop.jpg",
          "release_date": "1999-10-15",
          "vote_average": 8.4,
          "vote_count": 29696,
          "runtime": 139,
          "tagline": "Your mind is the scene of the crime.",
          "status": "Released",
          "genre_ids": [18, 28, 53]
        }
        """
        
        let movie = try decoder.decode(Movie.self, from: json.data(using: .utf8)!)
        
        XCTAssertEqual(movie.id, 550)
        XCTAssertEqual(movie.title, "Fight Club")
        XCTAssertEqual(movie.voteCount, 29696)
        XCTAssertEqual(movie.runtime, 139)
        XCTAssertEqual(movie.tagline, "Your mind is the scene of the crime.")
        XCTAssertEqual(movie.status, "Released")
        XCTAssertEqual(movie.genreIds, [18, 28, 53])
    }
    
    func testDecodeMovieWithNullNewFields() throws {
        let json = """
        {
          "id": 550,
          "title": "Fight Club",
          "vote_average": 8.4,
          "vote_count": null,
          "runtime": null,
          "tagline": null,
          "status": null,
          "genre_ids": null
        }
        """
        
        let movie = try decoder.decode(Movie.self, from: json.data(using: .utf8)!)
        
        XCTAssertEqual(movie.voteCount, 0)  // Default
        XCTAssertEqual(movie.runtime, 0)    // Default
        XCTAssertNil(movie.tagline)
        XCTAssertNil(movie.status)
        XCTAssertTrue(movie.genreIds.isEmpty)  // Default empty array
    }
    
    // MARK: - Encoding Tests
    
    func testEncodeMoviePreservesAllFields() throws {
        let originalMovie = Movie(
            id: 550,
            title: "Fight Club",
            overview: "An insomniac...",
            posterPath: "/poster.jpg",
            backdropPath: "/backdrop.jpg",
            releaseDate: "1999-10-15",
            voteAverage: 8.4,
            voteCount: 29696,
            runtime: 139,
            tagline: "Your mind...",
            status: "Released",
            genreIds: [18, 28, 53]
        )
        
        let encoded = try JSONEncoder().encode(originalMovie)
        let decodedMovie = try JSONDecoder().decode(Movie.self, from: encoded)
        
        XCTAssertEqual(decodedMovie.id, originalMovie.id)
        XCTAssertEqual(decodedMovie.title, originalMovie.title)
        XCTAssertEqual(decodedMovie.voteCount, originalMovie.voteCount)
        XCTAssertEqual(decodedMovie.runtime, originalMovie.runtime)
        XCTAssertEqual(decodedMovie.tagline, originalMovie.tagline)
        XCTAssertEqual(decodedMovie.status, originalMovie.status)
        XCTAssertEqual(decodedMovie.genreIds, originalMovie.genreIds)
    }
    
    // MARK: - Edge Cases
    
    func testDecodeMovieWithOnlyRequiredFields() throws {
        let json = """
        {
          "id": 550,
          "title": "Fight Club",
          "vote_average": 8.4
        }
        """
        
        let movie = try decoder.decode(Movie.self, from: json.data(using: .utf8)!)
        
        XCTAssertEqual(movie.id, 550)
        XCTAssertEqual(movie.title, "Fight Club")
        XCTAssertEqual(movie.voteAverage, 8.4)
        XCTAssertNil(movie.overview)
        XCTAssertNil(movie.posterPath)
        XCTAssertNil(movie.backdropPath)
        XCTAssertNil(movie.releaseDate)
        XCTAssertEqual(movie.voteCount, 0)
        XCTAssertEqual(movie.runtime, 0)
        XCTAssertNil(movie.tagline)
        XCTAssertNil(movie.status)
        XCTAssertTrue(movie.genreIds.isEmpty)
    }
    
    func testDecodeMovieWithLargeGenreIdsList() throws {
        let json = """
        {
          "id": 550,
          "title": "Fight Club",
          "genre_ids": [12, 14, 16, 18, 27, 28, 35, 36, 37, 53],
          "vote_average": 8.4
        }
        """
        
        let movie = try decoder.decode(Movie.self, from: json.data(using: .utf8)!)
        
        XCTAssertEqual(movie.genreIds.count, 10)
        XCTAssertTrue(movie.genreIds.contains(18))
        XCTAssertTrue(movie.genreIds.contains(53))
    }
}
