//
//  ShareSheetView.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 10/03/26.
//

import Foundation
import UIKit
import SwiftUI

struct ShareSheetView: UIViewControllerRepresentable {
    let items: [Any]
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        
        controller.completionWithItemsHandler = { _, _, _, _ in
            dismiss()
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
