//
//  FavoritesRepositoryTests.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 07/03/26.
//

import XCTest
import CoreData
@testable import MovieDB

final class FavoritesRepositoryTests: XCTestCase {
    var sut: FavoritesRepository!
    var mockContainer: NSPersistentContainer!
    
    override func setUp() {
        super.setUp()
        
        // Criar container in-memory simples
        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()
        entity.name = "MovieEntity"
        entity.managedObjectClassName = NSStringFromClass(MovieEntity.self)
        
        // Criar atributos
        let attributes: [NSAttributeDescription] = [
            createAttribute(name: "id", type: .integer32AttributeType, optional: false),
            createAttribute(name: "title", type: .stringAttributeType, optional: false),
            createAttribute(name: "overview", type: .stringAttributeType, optional: true),
            createAttribute(name: "posterPath", type: .stringAttributeType, optional: true),
            createAttribute(name: "backdropPath", type: .stringAttributeType, optional: true),
            createAttribute(name: "releaseDate", type: .stringAttributeType, optional: true),
            createAttribute(name: "voteAverage", type: .doubleAttributeType, optional: false)
        ]
        
        // Atribuir properties (funciona com array)
        entity.properties = attributes
        
        model.entities = [entity]
        
        mockContainer = NSPersistentContainer(name: "TestMovieDB", managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        mockContainer.persistentStoreDescriptions = [description]
        
        mockContainer.loadPersistentStores { _, error in
            if let error = error {
                XCTFail("Failed to load persistent stores: \(error)")
            }
        }
        
        mockContainer.viewContext.automaticallyMergesChangesFromParent = true
        sut = FavoritesRepository(container: mockContainer)
    }
    
    override func tearDown() {
        sut = nil
        mockContainer = nil
        super.tearDown()
    }
    
    // MARK: - Helper
    private func createAttribute(name: String, type: NSAttributeType, optional: Bool) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = optional
        return attribute
    }
    
    // MARK: - saveFavorite Tests
    func testSaveFavoriteSuccess() async throws {
        // Arrange
        let movie = Movie(
            id: 550,
            title: "Fight Club",
            overview: "An insomniac...",
            posterPath: "/path.jpg",
            backdropPath: "/backdrop.jpg",
            releaseDate: "1999-10-15",
            voteAverage: 8.4
        )
        
        // Act
        try await sut.saveFavorite(movie)
        
        // Assert
        let isFavorite = try await sut.isFavorite(movieId: 550)
        XCTAssertTrue(isFavorite)
    }
    
    func testSaveMultipleFavorites() async throws {
        // Arrange
        let movie1 = Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
        let movie2 = Movie(id: 2, title: "Movie 2", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 7.5)
        
        // Act
        try await sut.saveFavorite(movie1)
        try await sut.saveFavorite(movie2)
        
        // Assert
        let favorites = try await sut.fetchFavorites()
        XCTAssertEqual(favorites.count, 2)
    }
    
    // MARK: - removeFavorite Tests
    func testRemoveFavoriteSuccess() async throws {
        // Arrange
        let movie = Movie(id: 550, title: "Test", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
        try await sut.saveFavorite(movie)
        
        // Act
        try await sut.removeFavorite(movieId: 550)
        
        // Assert
        let isFavorite = try await sut.isFavorite(movieId: 550)
        XCTAssertFalse(isFavorite)
    }
    
    func testRemoveNonexistentFavorite() async throws {
        // Act & Assert (não deve lançar erro)
        try await sut.removeFavorite(movieId: 999)
    }
    
    // MARK: - fetchFavorites Tests
    func testFetchFavoritesEmpty() async throws {
        // Act
        let favorites = try await sut.fetchFavorites()
        
        // Assert
        XCTAssertTrue(favorites.isEmpty)
    }
    
    func testFetchFavoritesWithData() async throws {
        // Arrange
        let movie = Movie(id: 1, title: "Test", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
        try await sut.saveFavorite(movie)
        
        // Act
        let favorites = try await sut.fetchFavorites()
        
        // Assert
        XCTAssertEqual(favorites.count, 1)
        XCTAssertEqual(favorites.first?.id, 1)
    }
    
    func testFetchFavoritesMultiple() async throws {
        // Arrange
        for i in 1...5 {
            let movie = Movie(id: i, title: "Movie \(i)", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: Double(i))
            try await sut.saveFavorite(movie)
        }
        
        // Act
        let favorites = try await sut.fetchFavorites()
        
        // Assert
        XCTAssertEqual(favorites.count, 5)
    }
    
    // MARK: - isFavorite Tests
    func testIsFavoriteFalse() async throws {
        // Act
        let isFavorite = try await sut.isFavorite(movieId: 999)
        
        // Assert
        XCTAssertFalse(isFavorite)
    }
    
    func testIsFavoriteTrue() async throws {
        // Arrange
        let movie = Movie(id: 550, title: "Test", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
        try await sut.saveFavorite(movie)
        
        // Act
        let isFavorite = try await sut.isFavorite(movieId: 550)
        
        // Assert
        XCTAssertTrue(isFavorite)
    }
    
    // MARK: - Integration Tests
    func testSaveAndRemoveSameFavorite() async throws {
        // Arrange
        let movie = Movie(id: 1, title: "Test", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
        
        // Act & Assert
        try await sut.saveFavorite(movie)
        var isFavorite = try await sut.isFavorite(movieId: 1)
        XCTAssertTrue(isFavorite)
        
        try await sut.removeFavorite(movieId: 1)
        isFavorite = try await sut.isFavorite(movieId: 1)
        XCTAssertFalse(isFavorite)
    }
    
    func testFavoritesArePersistent() async throws {
        // Arrange
        let movie1 = Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 8.0)
        let movie2 = Movie(id: 2, title: "Movie 2", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: 7.0)
        
        // Act
        try await sut.saveFavorite(movie1)
        try await sut.saveFavorite(movie2)
        try await sut.removeFavorite(movieId: 1)
        
        // Assert
        let favorites = try await sut.fetchFavorites()
        XCTAssertEqual(favorites.count, 1)
        XCTAssertEqual(favorites.first?.id, 2)
    }
}
