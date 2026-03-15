//
//  HomeViewModelFilterTests.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 14/03/26.
//

import XCTest
@testable import MovieDB

@MainActor
final class HomeViewModelFilterTests: XCTestCase {
    
    var sut: HomeViewModel!
    var mockMovieRepository: MockMovieRepository!
    var mockFavoritesRepository: MockFavoritesRepository!
    
    @MainActor
    override func setUp() {
        super.setUp()
        mockMovieRepository = MockMovieRepository()
        mockFavoritesRepository = MockFavoritesRepository()
        sut = HomeViewModel(
            movieRepository: mockMovieRepository,
            favoritesRepository: mockFavoritesRepository
        )
    }
    
    override func tearDown() {
        sut = nil
        mockMovieRepository = nil
        mockFavoritesRepository = nil
        super.tearDown()
    }
    
    // MARK: - Filter Criteria Tests
    
    func testFilterCriteriaIsEmpty() {
        XCTAssertTrue(sut.filterCriteria.isEmpty)
    }
    
    func testFilterCriteriaIsNotEmptyWhenRatingSet() {
        sut.filterCriteria.minRating = 7.0
        
        XCTAssertFalse(sut.filterCriteria.isEmpty)
    }
    
    func testFilterCriteriaIsNotEmptyWhenGenresSelected() {
        sut.filterCriteria.selectedGenres.insert(28) // Action
        
        XCTAssertFalse(sut.filterCriteria.isEmpty)
    }
    
    func testFilterCriteriaResets() {
        sut.filterCriteria.minRating = 8.0
        sut.filterCriteria.selectedGenres.insert(28)
        
        sut.filterCriteria.reset()
        
        XCTAssertTrue(sut.filterCriteria.isEmpty)
        XCTAssertEqual(sut.filterCriteria.minRating, 0.0)
        XCTAssertTrue(sut.filterCriteria.selectedGenres.isEmpty)
    }
    
    // MARK: - Rating Filter Tests
    
    func testFilterMoviesByRating() async {
        let movies = [
            Movie(id: 1, title: "Movie 1", voteAverage: 9.0),
            Movie(id: 2, title: "Movie 2", voteAverage: 7.5),
            Movie(id: 3, title: "Movie 3", voteAverage: 5.0),
        ]
        mockMovieRepository.mockMovies = movies
        
        await sut.loadPopularMovies()
        
        sut.filterCriteria.minRating = 7.0
        
        XCTAssertEqual(sut.filteredMovies.count, 2)
        XCTAssertTrue(sut.filteredMovies.contains { $0.voteAverage == 9.0 })
        XCTAssertTrue(sut.filteredMovies.contains { $0.voteAverage == 7.5 })
        XCTAssertFalse(sut.filteredMovies.contains { $0.voteAverage == 5.0 })
    }
    
    // MARK: - Genre Filter Tests
    
    func testFilterMoviesByGenre() async {
        let movies = [
            Movie(id: 1, title: "Action Movie", voteAverage: 8.0, genreIds: [28]),
            Movie(id: 2, title: "Comedy Movie", voteAverage: 7.5, genreIds: [35]),
            Movie(id: 3, title: "Drama Movie", voteAverage: 8.5, genreIds: [18]),
        ]
        mockMovieRepository.mockMovies = movies
        
        await sut.loadPopularMovies()
        
        sut.filterCriteria.selectedGenres.insert(28) // Action
        
        XCTAssertEqual(sut.filteredMovies.count, 1)
        XCTAssertEqual(sut.filteredMovies.first?.title, "Action Movie")
    }
    
    func testFilterMoviesByMultipleGenres() async {
        let movies = [
            Movie(id: 1, title: "Action", voteAverage: 8.0, genreIds: [28]),
            Movie(id: 2, title: "Comedy", voteAverage: 7.5, genreIds: [35]),
            Movie(id: 3, title: "Action+Comedy", voteAverage: 7.8, genreIds: [28, 35]),
            Movie(id: 4, title: "Drama", voteAverage: 8.2, genreIds: [18]),
        ]
        mockMovieRepository.mockMovies = movies
        
        await sut.loadPopularMovies()
        
        sut.filterCriteria.selectedGenres.insert(28)  // Action
        sut.filterCriteria.selectedGenres.insert(35)  // Comedy
        
        // Deve retornar filmes que TÊM qualquer um dos gêneros selecionados
        XCTAssertEqual(sut.filteredMovies.count, 3)
    }
    
    func testToggleGenre() {
        sut.toggleGenre(.action)
        
        XCTAssertTrue(sut.filterCriteria.selectedGenres.contains(28))
    }
    
    func testToggleGenreRemoves() {
        sut.filterCriteria.selectedGenres.insert(28)
        
        sut.toggleGenre(.action)
        
        XCTAssertFalse(sut.filterCriteria.selectedGenres.contains(28))
    }
    
    // MARK: - Date Filter Tests
    
    func testFilterMoviesByStartDate() async {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let jan2020 = formatter.date(from: "2020-01-01")!
        let jan2021 = formatter.date(from: "2021-01-01")!
        let jan2022 = formatter.date(from: "2022-01-01")!
        
        let movies = [
            Movie(id: 1, title: "Old Movie", releaseDate: "2020-01-01", voteAverage: 8.0),
            Movie(id: 2, title: "Recent Movie", releaseDate: "2021-01-01", voteAverage: 8.0),
            Movie(id: 3, title: "New Movie", releaseDate: "2022-01-01", voteAverage: 8.0),
        ]
        mockMovieRepository.mockMovies = movies
        
        await sut.loadPopularMovies()
        
        sut.filterCriteria.startDate = jan2021
        
        XCTAssertEqual(sut.filteredMovies.count, 2)
        XCTAssertTrue(sut.filteredMovies.contains { $0.releaseDate == "2021-01-01" })
        XCTAssertTrue(sut.filteredMovies.contains { $0.releaseDate == "2022-01-01" })
    }
    
    func testFilterMoviesByEndDate() async {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let jan2021 = formatter.date(from: "2021-01-01")!
        
        let movies = [
            Movie(id: 1, title: "Old Movie", releaseDate: "2020-01-01", voteAverage: 8.0),
            Movie(id: 2, title: "Middle Movie", releaseDate: "2021-01-01", voteAverage: 8.0),
            Movie(id: 3, title: "New Movie", releaseDate: "2022-01-01", voteAverage: 8.0),
        ]
        mockMovieRepository.mockMovies = movies
        
        await sut.loadPopularMovies()
        
        sut.filterCriteria.endDate = jan2021
        
        XCTAssertEqual(sut.filteredMovies.count, 2)
    }
    
    // MARK: - Combined Filters Tests
    
    func testFilterMoviesByRatingAndGenre() async {
        let movies = [
            Movie(id: 1, title: "Good Action", voteAverage: 8.0, genreIds: [28]),
            Movie(id: 2, title: "Bad Action", voteAverage: 4.0, genreIds: [28]),
            Movie(id: 3, title: "Good Comedy", voteAverage: 8.0, genreIds: [35]),
        ]
        mockMovieRepository.mockMovies = movies
        
        await sut.loadPopularMovies()
        
        sut.filterCriteria.minRating = 7.0
        sut.filterCriteria.selectedGenres.insert(28) // Action
        
        XCTAssertEqual(sut.filteredMovies.count, 1)
        XCTAssertEqual(sut.filteredMovies.first?.title, "Good Action")
    }
    
    // MARK: - Active Filters Tests
    
    func testHasActiveFiltersWhenEmpty() {
        XCTAssertFalse(sut.hasActiveFilters)
    }
    
    func testHasActiveFiltersWhenRatingSet() {
        sut.filterCriteria.minRating = 7.0
        
        XCTAssertTrue(sut.hasActiveFilters)
    }
    
    func testActiveFilterCount() {
        XCTAssertEqual(sut.activeFilterCount, 0)
        
        sut.filterCriteria.minRating = 7.0
        XCTAssertEqual(sut.activeFilterCount, 1)
        
        sut.filterCriteria.selectedGenres.insert(28)
        XCTAssertEqual(sut.activeFilterCount, 2)
    }
    
    func testResetFilters() {
        sut.filterCriteria.minRating = 8.0
        sut.filterCriteria.selectedGenres.insert(28)
        
        sut.resetFilters()
        
        XCTAssertFalse(sut.hasActiveFilters)
        XCTAssertEqual(sut.activeFilterCount, 0)
    }

    func testDateStringConversion() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let validDate = formatter.date(from: "2020-01-15")
        XCTAssertNotNil(validDate)
        
        let invalidDate = formatter.date(from: "15-01-2020")
        XCTAssertNil(invalidDate)
    }

    func testFilterByDateWithStringConversion() async {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let movies = [
            Movie(id: 1, title: "Old", releaseDate: "2020-01-01", voteAverage: 8.0),
            Movie(id: 2, title: "New", releaseDate: "2023-01-01", voteAverage: 8.0),
        ]
        mockMovieRepository.mockMovies = movies
        
        await sut.loadPopularMovies()
        
        // Simula usuário digitando "2021-01-01"
        let dateString = "2021-01-01"
        if let date = formatter.date(from: dateString) {
            sut.filterCriteria.startDate = date
        }
        
        XCTAssertEqual(sut.filteredMovies.count, 1)
        XCTAssertEqual(sut.filteredMovies.first?.title, "New")
    }
}
