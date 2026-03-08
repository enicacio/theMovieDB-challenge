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
                let genreNames = MovieFormatter.genreNames(from: movie.genreIds)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Backdrop
                        CachedAsyncImage(url: movie.backdropURL)
                            .scaledToFill()
                            .frame(maxWidth: .infinity, minHeight: 200)
                            .clipped()
                        
                        // Content
                        VStack(alignment: .leading, spacing: 16) {
                            // Title
                            HStack(alignment: .top, spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(movie.title)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    // Tagline (if available)
                                    if let tagline = movie.tagline, !tagline.isEmpty {
                                        Text(tagline)
                                            .italic()
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
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Rating", systemImage: "")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                
                                HStack(spacing: 16) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                        Text(MovieFormatter.formatRating(movie.voteAverage))
                                            .fontWeight(.semibold)
                                    }
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.blue)
                                        Text("\(MovieFormatter.formatVoteCount(movie.voteCount)) votes")
                                            .font(.system(size: 14))
                                    }
                                    
                                    Spacer()
                                }
                                .font(.system(size: 16))
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            
                            Divider()
                            
                            // Release
                            if let releaseDate = movie.releaseDate, !releaseDate.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Label("Release Date", systemImage: "calendar")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                    
                                    Text(MovieFormatter.formatReleaseDate(releaseDate))
                                        .font(.system(size: 16, weight: .medium))
                                }
                            }
                            
                            // Runtime
                            if movie.runtime > 0 {
                                VStack(alignment: .leading, spacing: 8) {
                                    Label("Runtime", systemImage: "clock.fill")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                    
                                    Text(MovieFormatter.formatRuntime(movie.runtime))
                                        .font(.system(size: 16, weight: .medium))
                                }
                            }
                            
                            // Status
                            if let status = movie.status, !status.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Label("Status", systemImage: "checkmark.circle.fill")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                    
                                    Text(status)
                                        .font(.system(size: 16, weight: .medium))
                                }
                            }
                            
                            Divider()
                            
                            // Genres
                            if !genreNames.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Label("Genres", systemImage: "film.fill")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                    
                                    HStack {
                                        ForEach(genreNames, id: \.self) { genre in
                                            Text(genre)
                                                .font(.system(size: 12, weight: .medium))
                                                .padding(.vertical, 6)
                                                .padding(.horizontal, 12)
                                                .background(Color.blue.opacity(0.1))
                                                .foregroundColor(.blue)
                                                .cornerRadius(6)
                                        }
                                        Spacer()
                                    }
                                    .lineLimit(1)
                                }
                            }
                            
                            Divider()
                            
                            // Overview
                            if let overview = movie.overview, !overview.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Label("Overview", systemImage: "text.book.closed.fill")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                    
                                    Text(overview)
                                        .font(.system(size: 14))
                                        .lineSpacing(4)
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
        }
    }
}

#Preview {
    NavigationStack {
        MovieDetailView(movieId: 550)
    }
}
