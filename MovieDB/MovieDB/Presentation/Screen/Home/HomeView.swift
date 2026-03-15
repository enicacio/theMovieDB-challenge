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
                } else if viewModel.movies.isEmpty && !viewModel.searchText.isEmpty {
                    emptySearchState
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
    
    private var emptySearchState: some View {
        VStack(spacing: 0) {
            SearchBar(text: $viewModel.searchText, onClear: {
                Task {
                    await viewModel.loadPopularMovies()
                }
            })
            .onChange(of: viewModel.searchText) { oldValue, newValue in
                Task {
                    if !newValue.isEmpty {
                        await viewModel.searchMovies(query: newValue)
                    }
                }
            }
            .accessibilityIdentifier("searchBar")
            .padding(.vertical, 8)
            
            ScrollView {
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    
                    Text("Não encontramos filmes com '\(viewModel.searchText)'")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    
                    Button(action: {
                        viewModel.searchText = ""
                        Task {
                            await viewModel.loadPopularMovies()
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Limpar Busca")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
            }
        }
    }
    
    private var moviesList: some View {
        VStack(spacing: 0) {
            // Apenas SearchBar (sem filtros diretos)
            SearchBar(text: $viewModel.searchText)
                .onChange(of: viewModel.searchText) { oldValue, newValue in
                    Task {
                        await viewModel.searchMovies(query: newValue)
                    }
                }
                .accessibilityIdentifier("searchBar")
            
            // FILTROS INTEGRADOS EM UM SÓ LUGAR
            FilterBar(viewModel: viewModel)
            
            // Lista de filmes
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.filteredMovies) { movie in
                        NavigationLink(value: movie.id) {
                            MovieListCell(movie: movie) {
                                Task {
                                    await viewModel.toggleFavorite(movie: movie)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    
                    if !viewModel.isLoadingMore {
                        Button(action: {
                            Task {
                                await viewModel.loadMoreMovies()
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.down")
                                Text("Carregar Mais Filmes")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .foregroundColor(.primary)
                            .cornerRadius(8)
                        }
                        .accessibilityIdentifier("loadMoreButton")
                        .padding()
                    } else {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Carregando mais filmes...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                }
                .padding()
            }
            .accessibilityIdentifier("moviesTable")
        }
    }
}

#Preview {
    HomeView()
}
