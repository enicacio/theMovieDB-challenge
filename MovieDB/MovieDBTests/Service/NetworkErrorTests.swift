//
//  NetworkErrorTests.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 07/03/26.
//

import XCTest
@testable import MovieDB

final class NetworkErrorTests: XCTestCase {
    
    // MARK: - Error Description Tests
    func testInvalidURLErrorDescription() {
        let error = NetworkError.invalidURL
        XCTAssertEqual(error.errorDescription, "Invalid request URL")
    }
    
    func testNetworkUnavailableErrorDescription() {
        let error = NetworkError.networkUnavailable
        XCTAssertEqual(error.errorDescription, "Network is unavailable. Please check your internet connection.")
    }
    
    func testTimeoutErrorDescription() {
        let error = NetworkError.timedOut
        XCTAssertEqual(error.errorDescription, "Request timed out. Please try again.")
    }
    
    func testUnauthorizedErrorDescription() {
        let error = NetworkError.unauthorized
        XCTAssertEqual(error.errorDescription, "Unauthorized. Please login again.")
    }
    
    func testForbiddenErrorDescription() {
        let error = NetworkError.forbidden
        XCTAssertEqual(error.errorDescription, "Access forbidden.")
    }
    
    func testNotFoundErrorDescription() {
        let error = NetworkError.notFound
        XCTAssertEqual(error.errorDescription, "Resource not found.")
    }
    
    func testServerErrorDescription() {
        let error = NetworkError.serverError(statusCode: 500)
        let expected = "Server error (500). Please try again later."
        XCTAssertEqual(error.errorDescription, expected)
    }
    
    func testDecodingErrorDescription() {
        let error = NetworkError.decodingError(details: "Invalid JSON")
        XCTAssertTrue(error.errorDescription?.contains("Failed to parse response") ?? false)
    }
    
    func testUnknownErrorDescription() {
        let error = NetworkError.unknown
        XCTAssertEqual(error.errorDescription, "Something went wrong. Please try again.")
    }
    
    // MARK: - Retryable Tests
    func testNetworkUnavailableIsRetryable() {
        let error = NetworkError.networkUnavailable
        XCTAssertTrue(error.isRetryable)
    }
    
    func testTimeoutIsRetryable() {
        let error = NetworkError.timedOut
        XCTAssertTrue(error.isRetryable)
    }
    
    func testServerErrorIsRetryable() {
        let error = NetworkError.serverError(statusCode: 500)
        XCTAssertTrue(error.isRetryable)
    }
    
    func testInvalidURLIsNotRetryable() {
        let error = NetworkError.invalidURL
        XCTAssertFalse(error.isRetryable)
    }
    
    func testUnauthorizedIsNotRetryable() {
        let error = NetworkError.unauthorized
        XCTAssertFalse(error.isRetryable)
    }
    
    func testForbiddenIsNotRetryable() {
        let error = NetworkError.forbidden
        XCTAssertFalse(error.isRetryable)
    }
    
    func testNotFoundIsNotRetryable() {
        let error = NetworkError.notFound
        XCTAssertFalse(error.isRetryable)
    }
    
    func testDecodingErrorIsNotRetryable() {
        let error = NetworkError.decodingError()
        XCTAssertFalse(error.isRetryable)
    }
    
    func testUnknownIsNotRetryable() {
        let error = NetworkError.unknown
        XCTAssertFalse(error.isRetryable)
    }
    
    // MARK: - Identifiable Tests
    func testErrorHasUniqueID() {
        let error1 = NetworkError.invalidURL
        let error2 = NetworkError.networkUnavailable
        XCTAssertNotEqual(error1.id, error2.id)
    }
    
    // MARK: - Equatable Tests
    func testEquatableInvalidURL() {
        let error1 = NetworkError.invalidURL
        let error2 = NetworkError.invalidURL
        XCTAssertEqual(error1, error2)
    }
    
    func testEquatableServerError() {
        let error1 = NetworkError.serverError(statusCode: 500)
        let error2 = NetworkError.serverError(statusCode: 500)
        XCTAssertEqual(error1, error2)
    }
    
    func testNotEquatableDifferentErrors() {
        let error1 = NetworkError.invalidURL
        let error2 = NetworkError.networkUnavailable
        XCTAssertNotEqual(error1, error2)
    }
}
