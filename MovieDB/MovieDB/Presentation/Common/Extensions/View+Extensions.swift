//
//  View+Extensions.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 07/03/26.
//

import SwiftUI

extension View {
    /// Adiciona debounce a um binding
    func debounce(
        _ value: Binding<String>,
        delay: TimeInterval = 0.5,
        action: @escaping (String) -> Void
    ) -> some View {
        self.onChange(of: value.wrappedValue) { oldValue, newValue in
            Task {
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                action(newValue)
            }
        }
    }
}
