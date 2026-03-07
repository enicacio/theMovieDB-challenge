//
//  MovieRepositoryProtocol.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 06/03/26.
//

import Foundation

protocol MovieRepositoryProtocol {
    /// Busca filmes populares
    func fetchPopularMovies(page: Int) async throws -> [Movie]
    
    /// Busca filmes por query
    func searchMovies(query: String, page: Int) async throws -> [Movie]
    
    /// Busca gêneros
    func fetchGenres() async throws -> [Genre]
    
    /// Busca detalhes de um filme
    func fetchMovieDetails(id: Int) async throws -> Movie
}
