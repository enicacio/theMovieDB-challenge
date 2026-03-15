//
//  MovieGenre.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 14/03/26.
//

enum MovieGenre: Int, CaseIterable, Identifiable {
    var id: Int { self.rawValue }
    
    case action = 28
    case adventure = 12
    case animation = 16
    case comedy = 35
    case crime = 80
    case documentary = 99
    case drama = 18
    case family = 10751
    case fantasy = 14
    case history = 36
    case horror = 27
    case music = 10402
    case mystery = 9648
    case romance = 10749
    case scifi = 878
    case thriller = 53
    case tv = 10770
    case war = 10752
    case western = 37
    
    var displayName: String {
        switch self {
        case .action: return "Ação"
        case .adventure: return "Aventura"
        case .animation: return "Animação"
        case .comedy: return "Comédia"
        case .crime: return "Crime"
        case .documentary: return "Documentário"
        case .drama: return "Drama"
        case .family: return "Família"
        case .fantasy: return "Fantasia"
        case .history: return "História"
        case .horror: return "Terror"
        case .music: return "Música"
        case .mystery: return "Mistério"
        case .romance: return "Romance"
        case .scifi: return "Ficção Científica"
        case .thriller: return "Suspense"
        case .tv: return "TV Movie"
        case .war: return "Guerra"
        case .western: return "Faroeste"
        }
    }
}
