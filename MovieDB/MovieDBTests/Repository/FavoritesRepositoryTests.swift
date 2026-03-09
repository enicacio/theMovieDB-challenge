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
    var testDatabaseURL: URL?
    
    override func setUp() {
        super.setUp()
        
        // Cria container com SQLite temporário (novo para cada teste)
        mockContainer = createTestContainer()
        sut = FavoritesRepository(container: mockContainer)
    }
    
    override func tearDown() {
        do {
            if mockContainer.viewContext.hasChanges {
                try mockContainer.viewContext.save()
            }
            mockContainer.viewContext.reset()
        } catch {
            print("Erro ao salvar context: \(error)")
        }
        
        // Remover arquivo temporário
        if let url = testDatabaseURL {
            try? FileManager.default.removeItem(at: url)
        }
        
        sut = nil
        mockContainer = nil
        testDatabaseURL = nil
        super.tearDown()
    }
    
    // MARK: - Helper: Create Test Container
    /// Cria um container com SQLite temporário (novo para cada teste)
    private func createTestContainer() -> NSPersistentContainer {
        let coreDataStack = CoreDataStack()
        let model = coreDataStack.container.managedObjectModel
        let container = NSPersistentContainer(name: "MovieDB", managedObjectModel: model)
        
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("sqlite")
        
        self.testDatabaseURL = tempURL
        
        let description = NSPersistentStoreDescription(url: tempURL)
        description.type = NSSQLiteStoreType
        container.persistentStoreDescriptions = [description]
        
        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
        }
        
        if let error = loadError {
            fatalError("Erro ao carregar persistent store: \(error)")
        }
        
        return container
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
        let movie = Movie(
            id: 1,
            title: "Test",
            overview: "Test overview",
            posterPath: "/test.jpg",
            backdropPath: "/back.jpg",
            releaseDate: "2024-01-01",
            voteAverage: 8.0
        )
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
        XCTAssertEqual(favorites.count, 1, "Deve ter exatamente 1 filme")
        XCTAssertEqual(favorites.first?.id, 2, "Filme restante deve ser o ID 2")
    }
    
    // MARK: - New Fields Persistence Tests (Melhoria 4)
    func testSaveFavoriteWithAllNewFields() async throws {
        // Arrange
        let movie = Movie(
            id: 550,
            title: "Fight Club",
            voteAverage: 8.4,
            voteCount: 29696,
            runtime: 139,
            tagline: "Your mind is the scene of the crime.",
            status: "Released",
            genreIds: [18, 28, 53]
        )
        
        // Act
        try await sut.saveFavorite(movie)
        let favorites = try await sut.fetchFavorites()
        
        // Assert
        let saved = favorites.first(where: { $0.id == 550 })
        XCTAssertNotNil(saved)
        XCTAssertEqual(saved?.id, 550)
        XCTAssertEqual(saved?.title, "Fight Club")
        XCTAssertEqual(saved?.voteCount, 29696)
        XCTAssertEqual(saved?.runtime, 139)
        XCTAssertEqual(saved?.tagline, "Your mind is the scene of the crime.")
        XCTAssertEqual(saved?.status, "Released")
        XCTAssertEqual(saved?.genreIds, [18, 28, 53])
    }

    func testUpdateFavoriteWithNewFields() async throws {
        // Arrange - Salvar versão 1
        var movie1 = Movie(id: 550, title: "Fight Club", voteAverage: 8.4)
        try await sut.saveFavorite(movie1)
        
        // Arrange - Salvar versão 2 com novos campos
        var movie2 = Movie(
            id: 550,
            title: "Fight Club",
            voteAverage: 8.4,
            voteCount: 29696,
            runtime: 139,
            genreIds: [18, 28]
        )
        try await sut.saveFavorite(movie2)
        
        // Act
        let favorites = try await sut.fetchFavorites()
        let updated = favorites.first(where: { $0.id == 550 })
        
        // Assert
        XCTAssertEqual(favorites.count, 1, "Deve continuar com 1 filme (não duplicou)")
        XCTAssertEqual(updated?.voteCount, 29696, "voteCount deve ser 29696")
        XCTAssertEqual(updated?.runtime, 139, "runtime deve ser 139")
    }

    func testFetchFavoritesPreservesGenreIds() async throws {
        // Arrange
        let movie = Movie(
            id: 550,
            title: "Fight Club",
            voteAverage: 8.4,
            genreIds: [18, 28, 53]
        )
        
        // Act
        try await sut.saveFavorite(movie)
        let favorites = try await sut.fetchFavorites()
        
        // Assert
        XCTAssertEqual(favorites.first?.genreIds, [18, 28, 53])
    }
}
