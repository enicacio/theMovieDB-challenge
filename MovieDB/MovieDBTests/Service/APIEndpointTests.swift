//
//  APIEndpointTests.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 07/03/26.
//

import XCTest
@testable import MovieDB

final class APIEndpointTests: XCTestCase {
    
    // MARK: - Popular Movies Endpoint
    func testPopularMoviesEndpointPath() {
        let endpoint = APIEndpoint.popularMovies(page: 1)
        XCTAssertTrue(endpoint.path.contains("movie/popular"))
    }
    
    func testPopularMoviesPage1() {
        let endpoint = APIEndpoint.popularMovies(page: 1)
        XCTAssertTrue(endpoint.path.contains("popular"))
    }
    
    func testPopularMoviesPage2() {
        let endpoint = APIEndpoint.popularMovies(page: 2)
        XCTAssertTrue(endpoint.path.contains("popular"))
    }
    
    // MARK: - Search Movies Endpoint
    func testSearchMoviesEndpointPath() {
        let endpoint = APIEndpoint.searchMovies(query: "fight", page: 1)
        XCTAssertTrue(endpoint.path.contains("search/movie"))
    }
    
    func testSearchMoviesWithFight() {
        let endpoint = APIEndpoint.searchMovies(query: "fight", page: 1)
        XCTAssertTrue(endpoint.path.contains("search"))
    }
    
    func testSearchMoviesWithAvatar() {
        let endpoint = APIEndpoint.searchMovies(query: "avatar", page: 1)
        XCTAssertTrue(endpoint.path.contains("search"))
    }
    
    func testSearchMoviesPageParameter() {
        let endpoint1 = APIEndpoint.searchMovies(query: "test", page: 1)
        let endpoint2 = APIEndpoint.searchMovies(query: "test", page: 2)
        XCTAssertTrue(endpoint1.path.contains("search"))
        XCTAssertTrue(endpoint2.path.contains("search"))
    }
    
    // MARK: - Movie Details Endpoint
    func testMovieDetailsEndpointPath() {
        let endpoint = APIEndpoint.movieDetails(id: 550)
        XCTAssertTrue(endpoint.path.contains("movie/550"))
    }
    
    func testMovieDetailsID1() {
        let endpoint = APIEndpoint.movieDetails(id: 1)
        XCTAssertTrue(endpoint.path.contains("movie/1"))
    }
    
    func testMovieDetailsID2() {
        let endpoint = APIEndpoint.movieDetails(id: 2)
        XCTAssertTrue(endpoint.path.contains("movie/2"))
    }
    
    func testMovieDetailsID999() {
        let endpoint = APIEndpoint.movieDetails(id: 999)
        XCTAssertTrue(endpoint.path.contains("movie/999"))
    }
    
    // MARK: - Genres Endpoint
    func testGenresEndpointPath() {
        let endpoint = APIEndpoint.genres
        XCTAssertTrue(endpoint.path.contains("genre/movie/list"))
    }
    
    func testGenresEndpointValid() {
        let endpoint = APIEndpoint.genres
        XCTAssertFalse(endpoint.path.isEmpty)
    }
    
    // MARK: - Path Validity
    func testAllEndpointPathsStartWithSlash() {
        let endpoints: [APIEndpoint] = [
            .popularMovies(page: 1),
            .searchMovies(query: "test", page: 1),
            .movieDetails(id: 550),
            .genres
        ]
        
        for endpoint in endpoints {
            XCTAssertTrue(endpoint.path.starts(with: "/"),
                         "Path \(endpoint.path) should start with /")
        }
    }
    
    func testAllEndpointPathsNotEmpty() {
        let endpoints: [APIEndpoint] = [
            .popularMovies(page: 1),
            .searchMovies(query: "test", page: 1),
            .movieDetails(id: 550),
            .genres
        ]
        
        for endpoint in endpoints {
            XCTAssertFalse(endpoint.path.isEmpty)
        }
    }
}
