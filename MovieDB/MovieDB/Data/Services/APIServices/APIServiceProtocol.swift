//
//  APIServiceProtocol.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 06/03/26.
//

import Foundation

protocol APIServiceProtocol {
    
    func request<T: Decodable>(endpoint: APIEndpoint) async throws -> T
}
