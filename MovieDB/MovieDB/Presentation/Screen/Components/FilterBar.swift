//
//  FilterBar.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 14/03/26.
//

import SwiftUI

struct FilterBar: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                // Mostra badges dos filtros ativos
                if viewModel.filterCriteria.minRating > 0 {
                    Badge(
                        icon: "star.fill",
                        text: String(format: "%.1f★", viewModel.filterCriteria.minRating),
                        isActive: true
                    )
                }
                
                if !viewModel.filterCriteria.selectedGenres.isEmpty {
                    Badge(
                        icon: "film.fill",
                        text: "\(viewModel.filterCriteria.selectedGenres.count) gênero(s)",
                        isActive: true
                    )
                }
                
                if viewModel.filterCriteria.startDate != nil || viewModel.filterCriteria.endDate != nil {
                    Badge(
                        icon: "calendar",
                        text: "Data",
                        isActive: true
                    )
                }
                
                Spacer()
                
                // Botão para abrir FilterSheet
                Button(action: {
                    viewModel.showFilterSheet = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "line.3.horizontal.decrease")
                        
                        if viewModel.activeFilterCount > 0 {
                            Text("\(viewModel.activeFilterCount)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                .accessibilityIdentifier("openFilterSheet")
            }
            
            // Contagem de filmes
            Text("Mostrando \(viewModel.filteredMovies.count) de \(viewModel.movies.count) filmes")
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .sheet(isPresented: $viewModel.showFilterSheet) {
            FilterSheet(
                filterCriteria: $viewModel.filterCriteria,
                onApply: {},
                onReset: {
                    viewModel.resetFilters()
                }
            )
        }
    }
}
