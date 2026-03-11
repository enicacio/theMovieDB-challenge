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
    let formatter = MovieFormatter()
    
    private var genreNames: [String] {
        formatter.genreNames(from: movie.genreIds)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            CachedAsyncImage(url: movie.posterURL)
                .frame(width: 60, height: 90)
                .clipped()
                .cornerRadius(6)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(2)
                    .accessibilityIdentifier("movieTitle")
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(String(format: "%.1f", movie.voteAverage))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .accessibilityIdentifier("movieRating")
                }
                
                if let releaseDate = movie.releaseDate, !releaseDate.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text(releaseDate)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .accessibilityIdentifier("releaseDate")
                    }
                }
                
                if !genreNames.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "film.fill")
                            .font(.caption)
                            .foregroundColor(.purple)
                        Text(genreNames.prefix(2).joined(separator: ", "))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .accessibilityIdentifier("genres")
                    }
                }
            }
            .frame(maxHeight: 90, alignment: .topLeading)
            
            Spacer()
            
            Button(action: {
                isFavorite.toggle()
                onFavoriteTap()
            }) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(.red)
                    .font(.title3)
            }
            .accessibilityIdentifier("favoriteButton")
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .accessibilityIdentifier("movieCell_\(movie.id)")
    }
}

#Preview {
    MovieListCell(
        movie: Movie(
            id: 550,
            title: "Fight Club",
            overview: "An insomniac office worker and a devil-may-care soapmaker form an underground fight club that evolves into much more.",
            posterPath: nil,
            backdropPath: nil,
            releaseDate: "1999-10-15",
            voteAverage: 8.4,
            voteCount: 29696,
            runtime: 139,
            tagline: nil,
            status: nil,
            genreIds: [18, 28]
        ),
        onFavoriteTap: {}
    )
}
