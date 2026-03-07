//
//  APIServiceProtocol.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 06/03/26.
//

import Foundation

protocol APIServiceProtocol {
    
    /// Faz uma requisição genérica à API
    /// - Parameters:
    /// - endpoint: Endpoint a ser chamado
    /// - Returns: Resposta decodificada do tipo especificado
    /// - Throws: NetworkError em caso de falha
    func request<T: Decodable>(endpoint: APIEndpoint) async throws -> T
}
