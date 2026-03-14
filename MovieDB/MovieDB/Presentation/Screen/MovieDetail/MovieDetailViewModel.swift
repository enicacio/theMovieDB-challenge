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
    @Published var shareItems: [Any] = []
    @Published var showShare = false
    
    // MARK: - Private Properties
    private let movieRepository: MovieRepositoryProtocol
    private let favoritesRepository: FavoritesRepositoryProtocol
    private let movieId: Int
    private var tempShareFile: URL?
    
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
            
            // Preparar arquivo de compartilhamento enquanto carrega
            await prepareShareFile()
            
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
    
    /// Ação para compartilhar o filme
    /// Executa instantaneamente pois arquivo já foi preparado em loadMovieDetails
    func shareMovie() {
        if let tempFile = tempShareFile {
            shareItems = [tempFile]
            showShare = true
        }
    }
    
    // MARK: - Private Methods
    
    /// Prepara arquivo de compartilhamento em background
    /// Chamado automaticamente após loadMovieDetails completar
    private func prepareShareFile() async {
        guard let movie = movie,
              let url = movie.backdropURL,
              let cachedResponse = URLCache.shared.cachedResponse(for: URLRequest(url: url)) else {
            return
        }
        
        let imageData = cachedResponse.data
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("poster_\(UUID().uuidString).jpg")
        
        do {
            try imageData.write(to: tempFile)
            self.tempShareFile = tempFile
        } catch {
            AppLogger().logAPIError(NetworkError.unknown, context: "PrepareShareFile")
        }
    }
    
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
