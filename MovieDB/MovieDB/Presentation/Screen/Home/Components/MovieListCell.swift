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
    
    private var genreNames: [String] {
        MovieFormatter.genreNames(from: movie.genreIds)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Poster
            CachedAsyncImage(url: movie.posterURL)
                .frame(width: 60, height: 90)
                .clipped()
                .cornerRadius(6)
            
            // Info
            VStack(alignment: .leading, spacing: 8) {
                // Title
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(2)
                
                // Rating with Label
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(String(format: "%.1f", movie.voteAverage))
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                
                // Release Date with Label
                if let releaseDate = movie.releaseDate, !releaseDate.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text(releaseDate)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Genres with Label
                if !genreNames.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "film.fill")
                            .font(.caption)
                            .foregroundColor(.purple)
                        Text(genreNames.prefix(2).joined(separator: ", "))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            .frame(maxHeight: 90, alignment: .topLeading)
            
            Spacer()
            
            // Favorite Button
            Button(action: {
                isFavorite.toggle()
                onFavoriteTap()
            }) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(.red)
                    .font(.title3)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
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
