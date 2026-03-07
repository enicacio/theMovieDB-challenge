//
//  Genre.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 06/03/26.
//

import Foundation

struct Genre: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    
    // MARK: - Equatable
    static func == (lhs: Genre, rhs: Genre) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name
    }
}
