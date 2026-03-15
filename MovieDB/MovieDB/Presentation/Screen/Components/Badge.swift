//
//  Badge.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 14/03/26.
//

import SwiftUI

struct Badge: View {
    let icon: String
    let text: String
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            
            Text(text)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(isActive ? Color.blue.opacity(0.2) : Color(.systemGray5))
        .foregroundColor(isActive ? .blue : .secondary)
        .cornerRadius(6)
    }
}

#Preview {
    VStack(spacing: 10) {
        Badge(icon: "star.fill", text: "7.5★", isActive: true)
        Badge(icon: "film.fill", text: "2 gênero(s)", isActive: true)
        Badge(icon: "calendar", text: "Data", isActive: true)
        Badge(icon: "star.fill", text: "Inativo", isActive: false)
    }
    .padding()
}
