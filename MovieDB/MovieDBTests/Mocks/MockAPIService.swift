//
//  MockAPIService.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 07/03/26.
//

@testable import MovieDB

final class MockAPIService: APIServiceProtocol {
    var mockResponse: Any?
    var mockError: NetworkError?
    
    func request<T: Decodable>(endpoint: APIEndpoint) async throws -> T {
        if let error = mockError { throw error }
        
        if let response = mockResponse as? T {
            return response
        }
        
        throw NetworkError.unknown
    }
}
