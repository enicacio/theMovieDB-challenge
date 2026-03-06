//
//  APIService.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 06/03/26.
//

import Foundation

final class APIService: APIServiceProtocol {
    
    // MARK: - Properties
    
    private let client: APIClient
    
    // MARK: - Initialization
    
    init(client: APIClient = APIClient()) {
        self.client = client
    }
    
    // MARK: - APIServiceProtocol
    
    func request<T: Decodable>(endpoint: APIEndpoint) async throws -> T {
        let url = try buildURL(for: endpoint)
        return try await client.request(url: url, expecting: T.self)
    }
    
    // MARK: - Private Methods
    
    private func buildURL(for endpoint: APIEndpoint) throws -> URL {
        guard var components = URLComponents(
            string: Configuration.baseURL + endpoint.path
        ) else {
            throw NetworkError.invalidURL
        }
        components.queryItems = endpoint.queryItems
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        return url
    }
}
