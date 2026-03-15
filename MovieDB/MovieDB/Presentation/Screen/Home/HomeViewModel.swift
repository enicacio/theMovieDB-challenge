//
//  HomeViewModel.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 07/03/26.
//

import Foundation

struct ErrorMessage: Identifiable {
    let id = UUID()
    let title: String = "Error"
    let message: String
    let retryAction: (() -> Void)?
}

@MainActor
final class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var movies: [Movie] = []
    @Published var isLoading = false
    @Published var error: ErrorMessage?
    @Published var searchText = ""
    @Published var currentPage = 1
    @Published var isLoadingMore = false
    
    // MARK: - Filter Properties
    @Published var filterCriteria = FilterCriteria()
    @Published var showFilterSheet = false
    
    // MARK: - Computed property
    var filteredMovies: [Movie] {
        movies.filter { movie in
            applyFilters(to: movie)
        }
    }
    
    // MARK: - Private Properties
    private let movieRepository: MovieRepositoryProtocol
    private let favoritesRepository: FavoritesRepositoryProtocol
    
    // MARK: - Initialization
    init(
        movieRepository: MovieRepositoryProtocol = MovieRepository(),
        favoritesRepository: FavoritesRepositoryProtocol = FavoritesRepository()
    ) {
        self.movieRepository = movieRepository
        self.favoritesRepository = favoritesRepository
    }
    
    // MARK: - Filter Methods
    
    /// Aplica todos os filtros a um filme
    private func applyFilters(to movie: Movie) -> Bool {
        // Filter 1: Rating
        if movie.voteAverage < filterCriteria.minRating {
            return false
        }
        
        // Filter 2: Gêneros
        if !filterCriteria.selectedGenres.isEmpty {
            let hasGenre = movie.genreIds.contains { id in
                filterCriteria.selectedGenres.contains(id)
            }
            if !hasGenre {
                return false
            }
        }
        
        // Filter 3: Release Date
        if let startDate = filterCriteria.startDate,
           let releaseDate = movie.releaseDateAsDate,
           releaseDate < startDate {
            return false
        }
        
        if let endDate = filterCriteria.endDate,
           let releaseDate = movie.releaseDateAsDate,
           releaseDate > endDate {
            return false
        }
        
        return true
    }
    
    /// Toggle gênero na seleção
    func toggleGenre(_ genre: MovieGenre) {
        if filterCriteria.selectedGenres.contains(genre.rawValue) {
            filterCriteria.selectedGenres.remove(genre.rawValue)
        } else {
            filterCriteria.selectedGenres.insert(genre.rawValue)
        }
    }
    
    /// Reset todos os filtros
    func resetFilters() {
        filterCriteria.reset()
    }
    
    /// Check se há filtros ativos
    var hasActiveFilters: Bool {
        !filterCriteria.isEmpty
    }
    
    /// Contagem de filtros ativos
    var activeFilterCount: Int {
        var count = 0
        
        if filterCriteria.minRating > 0 {
            count += 1
        }
        
        if !filterCriteria.selectedGenres.isEmpty {
            count += 1
        }
        
        if filterCriteria.startDate != nil || filterCriteria.endDate != nil {
            count += 1
        }
        
        return count
    }
    
    // MARK: - Existing Methods (keep as is)
    
    func loadPopularMovies() async {
        isLoading = true
        error = nil
        
        do {
            movies = try await movieRepository.fetchPopularMovies(page: 1)
            currentPage = 1
            isLoading = false
        } catch let networkError as NetworkError {
            handleError(networkError, context: "LoadPopularMovies") {
                Task { await self.loadPopularMovies() }
            }
        } catch {
            let genericError = NetworkError.unknown
            handleError(genericError, context: "LoadPopularMovies") {
                Task { await self.loadPopularMovies() }
            }
        }
    }
    
    func searchMovies(query: String) async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            await loadPopularMovies()
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            movies = try await movieRepository.searchMovies(query: query, page: 1)
            currentPage = 1
            isLoading = false
        } catch let networkError as NetworkError {
            handleError(networkError, context: "SearchMovies") {
                Task { await self.searchMovies(query: query) }
            }
        } catch {
            let genericError = NetworkError.unknown
            handleError(genericError, context: "SearchMovies") {
                Task { await self.searchMovies(query: query) }
            }
        }
    }
    
    func toggleFavorite(movie: Movie) async {
        do {
            let isFavorite = try await favoritesRepository.isFavorite(movieId: movie.id)
            
            if isFavorite {
                try await favoritesRepository.removeFavorite(movieId: movie.id)
            } else {
                try await favoritesRepository.saveFavorite(movie)
            }
        } catch {
            let errorMsg = ErrorMessage(
                message: "Failed to update favorite",
                retryAction: {
                    Task { await self.toggleFavorite(movie: movie) }
                }
            )
            self.error = errorMsg
        }
    }
    
    func loadMoreMovies() async {
        isLoadingMore = true
        currentPage += 1
        
        do {
            let newMovies = try await movieRepository.fetchPopularMovies(page: currentPage)
            self.movies.append(contentsOf: newMovies)
        } catch {
            currentPage -= 1
            let errorMsg = ErrorMessage(
                message: "Erro ao carregar mais filmes",
                retryAction: { [weak self] in
                    Task { await self?.loadMoreMovies() }
                }
            )
            self.error = errorMsg
        }
        
        isLoadingMore = false
    }
    
    // MARK: - Private Methods
    
    private func handleError(
        _ error: NetworkError,
        context: String,
        retryAction: @escaping () -> Void
    ) {
        AppLogger().logAPIError(error, context: context)
        self.error = ErrorMessage(
            message: error.errorDescription ?? "Unknown error",
            retryAction: error.isRetryable ? retryAction : nil
        )
        isLoading = false
    }
}
