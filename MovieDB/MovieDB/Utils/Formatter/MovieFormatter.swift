//
//  MovieFormatter.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 08/03/26.
//

import Foundation

/// Utility namespace para formatação de dados de filmes
/// Usa enum em vez de struct para namespace puro (sem instância)
enum MovieFormatter {
    
    // MARK: - Genre Mapping
    
    /// Mapeamento de IDs de gênero para nomes em inglês
    /// Reutilizável em qualquer lugar do app
    static let genreMap: [Int: String] = [
        28: "Action",
        12: "Adventure",
        16: "Animation",
        35: "Comedy",
        80: "Crime",
        99: "Documentary",
        18: "Drama",
        10751: "Family",
        14: "Fantasy",
        36: "History",
        27: "Horror",
        10402: "Music",
        9648: "Mystery",
        10749: "Romance",
        878: "Science Fiction",
        10770: "TV Movie",
        53: "Thriller",
        10752: "War",
        37: "Western"
    ]
    
    /// Converte array de IDs de gênero para array de nomes
    /// - Parameter genreIds: Array de IDs de gênero
    /// - Returns: Array de nomes de gênero
    static func genreNames(from genreIds: [Int]) -> [String] {
        genreIds.compactMap { genreMap[$0] }
    }
    
    // MARK: - Date Formatting
    
    /// Converte string de data "YYYY-MM-DD" para formato "Month DD, YYYY"
    /// - Parameter dateString: Data em formato "YYYY-MM-DD"
    /// - Returns: Data formatada ou string original se parsing falhar
    static func formatReleaseDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter.string(from: date)
    }
    
    // MARK: - Time Formatting
    
    /// Converte minutos para formato "Xh Ymin"
    /// - Parameter minutes: Duração em minutos
    /// - Returns: String formatada (ex: "2h 19min")
    static func formatRuntime(_ minutes: Int) -> String {
        guard minutes > 0 else { return "" }
        
        let hours = minutes / 60
        let mins = minutes % 60
        
        if hours > 0 {
            return "\(hours)h \(mins)min"
        }
        return "\(mins)min"
    }
    
    // MARK: - Vote Count Formatting
    
    /// Converte número de votos para formato compacto
    /// - Parameter count: Número de votos
    /// - Returns: String formatada (ex: "29.7K", "1.2M")
    static func formatVoteCount(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000)
        } else if count >= 1_000 {
            return String(format: "%.1fK", Double(count) / 1_000)
        }
        return "\(count)"
    }
    
    // MARK: - Rating Formatting
    
    /// Formata rating com até 1 casa decimal
    /// - Parameter rating: Valor do rating (0-10)
    /// - Returns: String formatada (ex: "8.4")
    static func formatRating(_ rating: Double) -> String {
        return String(format: "%.1f", rating)
    }
    
    /// Retorna nome de gênero para um ID específico
    /// - Parameter genreId: ID do gênero
    /// - Returns: Nome do gênero ou nil se não encontrado
    static func genreName(for genreId: Int) -> String? {
        genreMap[genreId]
    }
    
    // MARK: - Truncation Formatting
    
    /// Trunca string para número máximo de caracteres
    /// - Parameters:
    ///   - text: Texto a truncar
    ///   - maxLength: Comprimento máximo
    /// - Returns: String truncada com "..." se necessário
    static func truncate(_ text: String, to maxLength: Int) -> String {
        guard text.count > maxLength else { return text }
        return String(text.prefix(maxLength)) + "..."
    }
    
    // MARK: - Combined Formatting
    
    /// Formata todos os dados principais de um filme para exibição
    /// - Parameter movie: Filme a formatar
    /// - Returns: Dictionary com dados formatados
    static func formatMovieForDisplay(_ movie: Movie) -> [String: String] {
        return [
            "title": movie.title,
            "releaseDate": movie.releaseDate.map { formatReleaseDate($0) } ?? "N/A",
            "rating": formatRating(movie.voteAverage),
            "voteCount": formatVoteCount(movie.voteCount),
            "runtime": movie.runtime > 0 ? formatRuntime(movie.runtime) : "N/A",
            "status": movie.status ?? "N/A",
            "genres": genreNames(from: movie.genreIds).joined(separator: ", ")
        ]
    }
}
