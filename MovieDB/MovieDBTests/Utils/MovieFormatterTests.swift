//
//  MovieFormatterTests.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 08/03/26.
//

import XCTest
@testable import MovieDB

class MovieFormatterTests: XCTestCase {
    
    // MARK: - Release Date Tests
    let formatter = MovieFormatter()
    
    func testFormatReleaseDateValid() {
        let result = formatter.formatReleaseDate("1999-10-15")
        XCTAssertEqual(result, "October 15, 1999")
    }
    
    func testFormatReleaseDateInvalid() {
        let result = formatter.formatReleaseDate("invalid-date")
        XCTAssertEqual(result, "invalid-date")  // Fallback
    }
    
    func testFormatReleaseDateEmpty() {
        let result = formatter.formatReleaseDate("")
        XCTAssertEqual(result, "")
    }
    
    // MARK: - Runtime Tests
    
    func testFormatRuntimeZero() {
        let result = formatter.formatRuntime(0)
        XCTAssertEqual(result, "")  // Ou "0min" conforme preferência
    }
    
    func testFormatRuntimeOnlyMinutes() {
        let result = formatter.formatRuntime(59)
        XCTAssertEqual(result, "59min")
    }
    
    func testFormatRuntimeHoursAndMinutes() {
        let result = formatter.formatRuntime(139)
        XCTAssertEqual(result, "2h 19min")
    }
    
    func testFormatRuntimeExactHours() {
        let result = formatter.formatRuntime(120)
        XCTAssertEqual(result, "2h 0min")
    }
    
    // MARK: - Vote Count Tests
    
    func testFormatVoteCountUnder1000() {
        let result = formatter.formatVoteCount(500)
        XCTAssertEqual(result, "500")
    }
    
    func testFormatVoteCountThousands() {
        let result = formatter.formatVoteCount(29696)
        XCTAssertEqual(result, "29.7K")
    }
    
    func testFormatVoteCountMillions() {
        let result = formatter.formatVoteCount(1200000)
        XCTAssertEqual(result, "1.2M")
    }
    
    // MARK: - Rating Tests
    
    func testFormatRatingOneDecimal() {
        let result = formatter.formatRating(8.438)
        XCTAssertEqual(result, "8.4")
    }
    
    func testFormatRatingRounding() {
        let result = formatter.formatRating(7.95)
        XCTAssertEqual(result, "8.0")
    }
    
    // MARK: - Genre Names Tests
    
    func testGenreNamesFromIds() {
        let genres = formatter.genreNames(from: [18, 28, 53])
        XCTAssertEqual(genres, ["Drama", "Action", "Thriller"])
    }
    
    func testGenreNamesEmptyArray() {
        let genres = formatter.genreNames(from: [])
        XCTAssertTrue(genres.isEmpty)
    }
    
    func testGenreNameForSingleId() {
        let name = formatter.genreName(for: 18)
        XCTAssertEqual(name, "Drama")
    }
    
    func testGenreNameForInvalidId() {
        let name = formatter.genreName(for: 9999)
        XCTAssertNil(name)
    }
}
