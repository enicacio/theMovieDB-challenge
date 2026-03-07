//
//  CachedAsyncImage.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 07/03/26.
//

import SwiftUI

struct CachedAsyncImage: View {
    let url: URL?
    @State private var image: UIImage?
    @State private var isLoading = false
    
    private static let imageCache = NSCache<NSString, UIImage>()
    
    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color(.systemGray6)
                    .overlay {
                        if isLoading {
                            ProgressView()
                        } else {
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        }
                    }
            }
        }
        .onAppear {
            Task {
                await loadImage()
            }
        }
    }
    
    private func loadImage() async {
        guard let url = url else { return }
        
        let key = url.absoluteString as NSString
        if let cached = Self.imageCache.object(forKey: key) {
            self.image = cached
            return
        }
        
        isLoading = true
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let uiImage = UIImage(data: data) {
                Self.imageCache.setObject(uiImage, forKey: key)
                self.image = uiImage
            }
        } catch {
            AppLogger().logAPIError(error, context: "CachedAsyncImage")
        }
        isLoading = false
    }
}
