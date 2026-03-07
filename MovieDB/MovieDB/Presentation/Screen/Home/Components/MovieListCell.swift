//
//  MovieListCell.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 07/03/26.
//

import SwiftUI

struct MovieListCell: View {
    let movie: Movie
    let onFavoriteTap: () -> Void
    @State private var isFavorite = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Poster
            CachedAsyncImage(url: movie.posterURL)
                .frame(width: 60, height: 90)
                .clipped()
                .cornerRadius(6)
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(2)
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(String(format: "%.1f", movie.voteAverage))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let releaseDate = movie.releaseDate {
                    Text(releaseDate)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Favorite Button
            Button(action: {
                isFavorite.toggle()
                onFavoriteTap()
            }) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(.red)
                    .font(.title3)
                    .scaleEffect(1.2)
                    .animation(.spring(response: 0.3), value: isFavorite)
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    MovieListCell(movie: Movie(
        id: 1,
        title: "Test",
        overview: nil,
        posterPath: nil,
        backdropPath: nil,
        releaseDate: nil,
        voteAverage: 8.0
    ), onFavoriteTap: {})
}
