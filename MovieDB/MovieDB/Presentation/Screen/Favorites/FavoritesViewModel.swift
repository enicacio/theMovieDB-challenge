//
//  FavoritesViewModel.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 07/03/26.
//

import Foundation

@MainActor
final class FavoritesViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var favorites: [Movie] = []
    @Published var isLoading = false
    @Published var error: ErrorMessage?
    
    // MARK: - Private Properties
    private let favoritesRepository: FavoritesRepositoryProtocol
    
    // MARK: - Initialization
    init(favoritesRepository: FavoritesRepositoryProtocol = FavoritesRepository()) {
        self.favoritesRepository = favoritesRepository
    }
    
    // MARK: - Public Methods
    func loadFavorites() async {
        isLoading = true
        error = nil
        
        do {
            favorites = try await favoritesRepository.fetchFavorites()
            isLoading = false
        } catch let networkError as NetworkError {
            handleError(networkError, context: "LoadFavorites") {
                Task { await self.loadFavorites() }
            }
        } catch {
            // Qualquer outro erro
            let genericError = NetworkError.unknown
            handleError(genericError, context: "LoadFavorites") {
                Task { await self.loadFavorites() }
            }
        }
    }
    
    func removeFavorite(movieId: Int) async {
        do {
            try await favoritesRepository.removeFavorite(movieId: movieId)
            favorites.removeAll { $0.id == movieId }
        } catch let networkError as NetworkError {
            let errorMsg = ErrorMessage(
                message: "Failed to remove favorite",
                retryAction: {
                    Task { await self.removeFavorite(movieId: movieId) }
                }
            )
            self.error = errorMsg
        } catch {
            let errorMsg = ErrorMessage(
                message: "Failed to remove favorite",
                retryAction: {
                    Task { await self.removeFavorite(movieId: movieId) }
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
