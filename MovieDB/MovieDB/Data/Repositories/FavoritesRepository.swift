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
        let entity = MovieEntity(context: container.viewContext)
        entity.id = Int32(exactly: movie.id) ?? 0
        entity.title = movie.title
        entity.overview = movie.overview
        entity.posterPath = movie.posterPath
        entity.backdropPath = movie.backdropPath
        entity.releaseDate = movie.releaseDate
        entity.voteAverage = movie.voteAverage
        
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
                voteAverage: entity.voteAverage
            )
        }
    }
    
    func isFavorite(movieId: Int) async throws -> Bool {
        let fetchRequest = MovieEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", movieId)
        
        let count = try container.viewContext.count(for: fetchRequest)
        return count > 0
    }
}
