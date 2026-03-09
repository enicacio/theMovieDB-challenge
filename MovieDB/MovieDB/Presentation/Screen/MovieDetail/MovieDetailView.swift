//
//  MovieDetailView.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 07/03/26.
//

import SwiftUI

struct MovieDetailView: View {
    let movieId: Int
    @StateObject private var viewModel: MovieDetailViewModel
    
    init(movieId: Int) {
        self.movieId = movieId
        _viewModel = StateObject(
            wrappedValue: MovieDetailViewModel(movieId: movieId)
        )
    }
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                LoadingView()
            } else if let error = viewModel.error {
                ErrorView(error: error, onRetry: {
                    error.retryAction?()
                })
            } else if let movie = viewModel.movie {
                ScrollView {
                    VStack(alignment: .leading) {
                        // Backdrop
                        CachedAsyncImage(url: movie.backdropURL)
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .clipped()
                        
                        // Content
                        VStack(alignment: .leading) {
                            // Title
                            HStack(alignment: .top) {
                                VStack(alignment: .leading) {
                                    Text(movie.title)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    if !viewModel.genreNames.isEmpty {
                                        Text(viewModel.genreNames.joined(separator: ", "))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    Task {
                                        await viewModel.toggleFavorite()
                                    }
                                }) {
                                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                                        .font(.title2)
                                        .foregroundColor(.red)
                                }
                            }
                            
                            // Rating
                            HStack {
                                Label(
                                    String(format: "%.1f", movie.voteAverage),
                                    systemImage: "star.fill"
                                )
                                .foregroundColor(.yellow)
                                
                                Spacer()
                                
                                if let releaseDate = movie.releaseDate, !releaseDate.isEmpty {
                                    Text(releaseDate)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Divider()
                            
                            // Overview
                            if let overview = movie.overview, !overview.isEmpty {
                                VStack(alignment: .leading) {
                                    Text("Overview")
                                        .font(.headline)
                                    
                                    Text(overview)
                                        .font(.body)
                                }
                            }
                        }
                        .padding()
                    }
                }
            } else {
                EmptyStateView()
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadMovieDetails()
            await viewModel.loadGenres()
        }
    }
}

#Preview {
    NavigationStack {
        MovieDetailView(movieId: 550)
    }
}
