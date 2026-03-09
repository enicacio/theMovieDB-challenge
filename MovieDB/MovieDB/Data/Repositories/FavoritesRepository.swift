//
//  FavoritesRepository.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 07/03/26.
//

import Foundation
import CoreData

final class FavoritesRepository: FavoritesRepositoryProtocol {
    // MARK: - Properties
    private let container: NSPersistentContainer
    
    // MARK: - Initialization
    init(container: NSPersistentContainer = CoreDataStack().container) {
        self.container = container
    }
    
    // MARK: - FavoritesRepositoryProtocol
    func saveFavorite(_ movie: Movie) async throws {
        // Procurar se já existe com este ID
        let fetchRequest = MovieEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", movie.id)
        
        let results = try container.viewContext.fetch(fetchRequest)
        
        // Se existe, atualizar; se não, criar novo
        let entity: MovieEntity
        if let existing = results.first {
            entity = existing  // ✅ ATUALIZAR registro existente
        } else {
            entity = MovieEntity(context: container.viewContext)  // Criar novo
        }
        
        entity.id = Int32(exactly: movie.id) ?? 0
        entity.title = movie.title
        entity.overview = movie.overview
        entity.posterPath = movie.posterPath
        entity.backdropPath = movie.backdropPath
        entity.releaseDate = movie.releaseDate
        entity.voteAverage = movie.voteAverage
        entity.voteCount = Int32(exactly: movie.voteCount) ?? 0
        entity.runtime = Int32(exactly: movie.runtime) ?? 0
        entity.tagline = movie.tagline
        entity.status = movie.status
        entity.genres = encodeGenres(movie.genreIds)
        
        try container.viewContext.save()
    }
    
    func removeFavorite(movieId: Int) async throws {
        let fetchRequest = MovieEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", movieId)
        
        let results = try container.viewContext.fetch(fetchRequest)
        results.forEach { container.viewContext.delete($0) }
        
        try container.viewContext.save()
    }
    
    func fetchFavorites() async throws -> [Movie] {
        let fetchRequest = MovieEntity.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \MovieEntity.id, ascending: false)
        ]
        
        let entities = try container.viewContext.fetch(fetchRequest)
        return entities.compactMap { entity in
            Movie(
                id: Int(entity.id),
                title: entity.title ?? "",
                overview: entity.overview,
                posterPath: entity.posterPath,
                backdropPath: entity.backdropPath,
                releaseDate: entity.releaseDate,
                voteAverage: entity.voteAverage,
                voteCount: Int(entity.voteCount),
                runtime: Int(entity.runtime),
                tagline: entity.tagline,
                status: entity.status,
                genreIds: decodeGenres(entity.genres)
            )
        }
    }
    
    func isFavorite(movieId: Int) async throws -> Bool {
        let fetchRequest = MovieEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", movieId)
        
        let count = try container.viewContext.count(for: fetchRequest)
        return count > 0
    }
    
    // MARK: - Helper Methods
    /// Codifica array de genreIds como string JSON para armazenar em CoreData
    private func encodeGenres(_ genreIds: [Int]) -> String {
        let jsonData = try? JSONEncoder().encode(genreIds)
        guard let jsonData = jsonData else { return "[]" }
        return String(data: jsonData, encoding: .utf8) ?? "[]"
    }
    
    /// Decodifica string JSON de volta para array de genreIds
    private func decodeGenres(_ jsonString: String?) -> [Int] {
        guard let jsonString = jsonString, !jsonString.isEmpty else { return [] }
        guard let data = jsonString.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([Int].self, from: data)) ?? []
    }
}
