//
//  MovieDetailViewModel.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 07/03/26.
//

import Foundation

@MainActor
final class MovieDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var movie: Movie?
    @Published var isLoading = false
    @Published var error: ErrorMessage?
    @Published var isFavorite = false
    
    // MARK: - Private Properties
    private let movieRepository: MovieRepositoryProtocol
    private let favoritesRepository: FavoritesRepositoryProtocol
    private let movieId: Int
    
    // MARK: - Initialization
    init(
        movieId: Int,
        movieRepository: MovieRepositoryProtocol = MovieRepository(),
        favoritesRepository: FavoritesRepositoryProtocol = FavoritesRepository()
    ) {
        self.movieId = movieId
        self.movieRepository = movieRepository
        self.favoritesRepository = favoritesRepository
    }
    
    // MARK: - Public Methods
    func loadMovieDetails() async {
        isLoading = true
        error = nil
        
        do {
            movie = try await movieRepository.fetchMovieDetails(id: movieId)
            isFavorite = try await favoritesRepository.isFavorite(movieId: movieId)
            isLoading = false
        } catch let networkError as NetworkError {
            handleError(networkError, context: "LoadMovieDetails") {
                Task { await self.loadMovieDetails() }
            }
        } catch {
            let genericError = NetworkError.unknown
            handleError(genericError, context: "LoadMovieDetails") {
                Task { await self.loadMovieDetails() }
            }
        }
    }
    
    func toggleFavorite() async {
        guard let movie = movie else { return }
        
        do {
            isFavorite = !isFavorite
            
            if isFavorite {
                try await favoritesRepository.saveFavorite(movie)
            } else {
                try await favoritesRepository.removeFavorite(movieId: movie.id)
            }
        } catch let networkError as NetworkError {
            isFavorite = !isFavorite // Revert
            let errorMsg = ErrorMessage(
                message: networkError.errorDescription ?? "Failed to update favorite",
                retryAction: {
                    Task { await self.toggleFavorite() }
                }
            )
            self.error = errorMsg
        } catch {
            isFavorite = !isFavorite // Revert
            let errorMsg = ErrorMessage(
                message: "Failed to update favorite",
                retryAction: {
                    Task { await self.toggleFavorite() }
                }
            )
            self.error = errorMsg
        }
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
