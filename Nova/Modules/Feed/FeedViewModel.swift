//
//  FeedViewModel.swift
//  Nova
//
//  Created by Wahab on 04/08/2026.
//

import Foundation
import Combine
import FirebaseFirestoreInternal
import FirebaseFirestore

@MainActor
final class FeedViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchPosts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let snapshot = try await FirestoreManager.shared.db.collection("posts")
                .order(by: "createdAt", descending: true)
                .limit(to: 20)
                .getDocuments()
            
            posts = try snapshot.documents.compactMap {
                doc in
                try doc.data(as: Post.self)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
