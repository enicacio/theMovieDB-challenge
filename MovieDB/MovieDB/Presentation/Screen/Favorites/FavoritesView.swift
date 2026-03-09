//
//  FavoritesView.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 07/03/26.
//

import SwiftUI

import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel()
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                if viewModel.isLoading && viewModel.favorites.isEmpty {
                    LoadingView()
                } else if let error = viewModel.error {
                    ErrorView(error: error, onRetry: {
                        error.retryAction?()
                    })
                } else if viewModel.favorites.isEmpty {
                    EmptyStateView(message: "No favorite movies yet")
                } else {
                    List(viewModel.favorites) { movie in
                        NavigationLink(value: movie.id) {
                            MovieListCell(movie: movie) {
                                Task {
                                    await viewModel.removeFavorite(movieId: movie.id)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Favorites")
            .navigationDestination(for: Int.self) { movieId in
                MovieDetailView(movieId: movieId)
            }
            .task {
                await viewModel.loadFavorites()
            }
        }
    }
}

#Preview {
    FavoritesView()
}
