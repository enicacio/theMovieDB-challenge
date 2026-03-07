//
//  MockAPIService.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 06/03/26.
//

import Foundation

final class MockAPIService: APIServiceProtocol {
    
    // MARK: - Properties
    var mockResponse: Any?
    var mockError: NetworkError?
    
    // MARK: - APIServiceProtocol
    func request<T: Decodable>(endpoint: APIEndpoint) async throws -> T {
        if let error = mockError {
            throw error
        }
        
        if let response = mockResponse as? T {
            return response
        }
        
        throw NetworkError.unknown
    }
}
