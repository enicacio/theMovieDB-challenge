//
//  MovieRepositoryIntegrationTests.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 09/03/26.
//

import XCTest
@testable import MovieDB

class MovieRepositoryIntegrationTests: XCTestCase {
    var sut: FavoritesRepository!
    
    override func setUp() {
        super.setUp()
        sut = FavoritesRepository()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - FavoritesRepository Integration Tests
    
    func testSaveAndFetchFavoriteIntegration() async throws {
        // Arrange
        let movie = Movie(id: 550, title: "Fight Club", voteAverage: 8.4)
        
        // Act - Salva de verdade no CoreData
        try await sut.saveFavorite(movie)
        
        // Assert - Busca de verdade do CoreData
        let isFavorite = try await sut.isFavorite(movieId: 550)
        XCTAssertTrue(isFavorite, "Filme deve estar nos favoritos após salvar")
    }
    
    func testSaveFavoriteAndFetch() async throws {
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
        XCTAssertNotNil(saved, "Filme salvo deve estar em fetchFavorites()")
        XCTAssertEqual(saved?.title, "Fight Club")
        XCTAssertEqual(saved?.voteCount, 29696)
        XCTAssertEqual(saved?.runtime, 139)
        XCTAssertEqual(saved?.genreIds, [18, 28, 53])
    }
    
    // MARK: - MovieRepository Integration Tests
    
    /// Teste de integração: APIClient + MovieRepository
    /// ⚠️ AVISO: Este teste faz requisição de rede de verdade!
    /// Use apenas ocasionalmente (não em CI/CD)
    func testFetchPopularMoviesIntegration() async throws {
        let repository = MovieRepository()
        
        let movies = try await repository.fetchPopularMovies(page: 1)
        
        XCTAssertGreaterThan(
            movies.count,
            0,
            "Deve retornar filmes populares da API real"
        )
        
        // Verificar estrutura do filme
        if let firstMovie = movies.first {
            XCTAssertGreaterThan(firstMovie.id, 0)
            XCTAssertFalse(firstMovie.title.isEmpty)
            XCTAssertGreaterThanOrEqual(firstMovie.voteAverage, 0)
        }
    }
    
    // MARK: - HomeViewModel Integration Tests
    
    /// Teste de integração: HomeViewModel + Real Repository + Real API
    /// ⚠️ AVISO: Este teste usa rede de verdade!
    @MainActor
    func testHomeViewModelWithRealRepository() async throws {
        let repository = MovieRepository()
        let viewModel = HomeViewModel(movieRepository: repository)
        
        // Act
        await viewModel.loadPopularMovies()
        
        // Assert
        XCTAssertGreaterThan(
            viewModel.movies.count,
            0,
            "ViewModel deve carregar filmes populares via repository real"
        )
        XCTAssertFalse(
            viewModel.isLoading,
            "isLoading deve ser false após carregar"
        )
    }
    
    /// Teste: Buscar filme com real repository
    @MainActor
    func testHomeViewModelSearchWithRealRepository() async throws {
        let repository = MovieRepository()
        let viewModel = HomeViewModel(movieRepository: repository)
        
        // Act
        await viewModel.searchMovies(query: "Avatar")
        
        // Assert
        XCTAssertGreaterThan(
            viewModel.movies.count,
            0,
            "Deve encontrar filmes com busca 'Avatar'"
        )
    }
}
