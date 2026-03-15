//
//  FilterSheet.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 14/03/26.
//

import SwiftUI

struct FilterSheet: View {
    @Binding var filterCriteria: FilterCriteria
    @Environment(\.dismiss) var dismiss
    let onApply: () -> Void
    let onReset: () -> Void
    
    @State private var startDateText: String = ""
    @State private var endDateText: String = ""
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Rating Filter
                Section("Mínimo de Rating") {
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            
                            Text(String(format: "Mínimo: %.1f", filterCriteria.minRating))
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text(String(format: "%.1f/10", filterCriteria.minRating))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(
                            value: $filterCriteria.minRating,
                            in: 0...10,
                            step: 0.5
                        )
                        .accessibilityIdentifier("filterRatingSlider")
                    }
                }
                
                // MARK: - Genre Filter
                Section("Gêneros") {
                    ForEach(MovieGenre.allCases, id: \.id) { genre in
                        Toggle(isOn: Binding(
                            get: {
                                filterCriteria.selectedGenres.contains(genre.rawValue)
                            },
                            set: { isSelected in
                                if isSelected {
                                    filterCriteria.selectedGenres.insert(genre.rawValue)
                                } else {
                                    filterCriteria.selectedGenres.remove(genre.rawValue)
                                }
                            }
                        )) {
                            Text(genre.displayName)
                        }
                        .accessibilityIdentifier("genre_\(genre.displayName)")
                    }
                }
                
                // MARK: - Release Date Filter (com TextFields)
                Section("Data de Lançamento") {
                    VStack(spacing: 15) {
                        // Campo "De" (start date)
                        VStack(alignment: .leading, spacing: 8) {
                            Label("A partir de:", systemImage: "calendar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            TextField(
                                "yyyy-MM-dd",
                                text: $startDateText
                            )
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.default)
                            .accessibilityIdentifier("filterStartDateText")
                            .onChange(of: startDateText) { oldValue, newValue in
                                // Converte string para Date quando usuário digita
                                if !newValue.isEmpty, let date = dateFormatter.date(from: newValue) {
                                    filterCriteria.startDate = date
                                } else if newValue.isEmpty {
                                    filterCriteria.startDate = nil
                                }
                            }
                            
                            if !startDateText.isEmpty && dateFormatter.date(from: startDateText) == nil {
                                Text("Formato inválido. Use: yyyy-MM-dd")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // Campo "Até" (end date)
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Até:", systemImage: "calendar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            TextField(
                                "yyyy-MM-dd",
                                text: $endDateText
                            )
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.default)
                            .accessibilityIdentifier("filterEndDateText")
                            .onChange(of: endDateText) { oldValue, newValue in
                                // Converte string para Date quando usuário digita
                                if !newValue.isEmpty, let date = dateFormatter.date(from: newValue) {
                                    filterCriteria.endDate = date
                                } else if newValue.isEmpty {
                                    filterCriteria.endDate = nil
                                }
                            }
                            
                            if !endDateText.isEmpty && dateFormatter.date(from: endDateText) == nil {
                                Text("Formato inválido. Use: yyyy-MM-dd")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // Helper text
                        Text("Digite no formato YYYY-MM-DD\nExemplo: 2020-01-15")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                    }
                }
            }
            .navigationTitle("Filtros")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Limpar") {
                        startDateText = ""
                        endDateText = ""
                        onReset()
                    }
                    .foregroundColor(.red)
                    .accessibilityIdentifier("resetFiltersButton")
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button(action: {
                    onApply()
                    dismiss()
                }) {
                    Text("Aplicar Filtros")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                .background(Color(.systemBackground))
                .accessibilityIdentifier("applyFiltersButton")
            }
            .onAppear {
                // Preenche os campos com datas existentes quando abre a sheet
                if let startDate = filterCriteria.startDate {
                    startDateText = dateFormatter.string(from: startDate)
                }
                if let endDate = filterCriteria.endDate {
                    endDateText = dateFormatter.string(from: endDate)
                }
            }
        }
    }
}
