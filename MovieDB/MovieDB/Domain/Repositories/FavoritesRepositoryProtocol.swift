//
//  FavoritesRepositoryProtocol.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 06/03/26.
//

import Foundation

protocol FavoritesRepositoryProtocol {
    /// Salva um filme como favorito
    func saveFavorite(_ movie: Movie) async throws
    
    /// Remove um filme dos favoritos
    func removeFavorite(movieId: Int) async throws
    
    /// Obtém lista de favoritos
    func fetchFavorites() async throws -> [Movie]
    
    /// Verifica se um filme é favorito
    func isFavorite(movieId: Int) async throws -> Bool
}
