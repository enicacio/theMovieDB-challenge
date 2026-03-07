//
//  HomeView.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 07/03/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                if viewModel.isLoading && viewModel.movies.isEmpty {
                    LoadingView()
                } else if let error = viewModel.error {
                    ErrorView(error: error, onRetry: {
                        error.retryAction?()
                    })
                } else if viewModel.movies.isEmpty {
                    EmptyStateView(message: "No movies found")
                } else {
                    moviesList
                }
            }
            .navigationTitle("Popular Movies")
            .navigationDestination(for: Int.self) { movieId in
                MovieDetailView(movieId: movieId)
            }
            .task {
                await viewModel.loadPopularMovies()
            }
        }
    }
    
    private var moviesList: some View {
        VStack(spacing: 0) {
            SearchBar(text: $viewModel.searchText)
                .onChange(of: viewModel.searchText) { oldValue, newValue in
                    Task {
                        await viewModel.searchMovies(query: newValue)
                    }
                }
            
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.movies) { movie in
                        NavigationLink(value: movie.id) {
                            MovieListCell(movie: movie) {
                                Task {
                                    await viewModel.toggleFavorite(movie: movie)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    HomeView()
}
