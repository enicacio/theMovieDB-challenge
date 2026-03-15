//
//  FilterCriteria.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 14/03/26.
//

import Foundation
 
struct FilterCriteria {
    var minRating: Double = 0.0
    var selectedGenres: Set<Int> = []
    var startDate: Date?
    var endDate: Date?
    
    var isEmpty: Bool {
        minRating == 0.0 &&
        selectedGenres.isEmpty &&
        startDate == nil &&
        endDate == nil
    }
    
    mutating func reset() {
        self = FilterCriteria()
    }
}
