//
//  RetryableAsyncImage.swift
//  Nova
//
//  Created by Wahab on 06/08/2026.
//

import SwiftUI

struct RetryableAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder

    @State private var loadedImage: UIImage?
    @State private var isLoading = true
    @State private var failedAttempts = 0

    private let maxRetries = 2

    var body: some View {
        Group {
            if let loadedImage = loadedImage {
                content(Image(uiImage: loadedImage))
            } else {
                placeholder()
            }
        }
        .task(id: url) {
            await loadImage()
        }
    }

    func loadImage() async {
        guard let url = url else {
            isLoading = false
            return
        }
        isLoading = true
        failedAttempts = 0

        while failedAttempts <= maxRetries {
            do {
                var request = URLRequest(url: url)
                request.timeoutInterval = 20
                let (data, _) = try await URLSession.shared.data(for: request)
                if let uiImage = UIImage(data: data) {
                    loadedImage = uiImage
                    isLoading = false
                    return
                }
            } catch {
                failedAttempts += 1
                if failedAttempts <= maxRetries {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                }
            }
        }
        isLoading = false
    }
}
