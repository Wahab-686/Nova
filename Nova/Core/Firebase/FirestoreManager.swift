//
//   FirestoreManager.swift
//  Nova
//
//  Created by Wahab on 30/07/2026.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FirestoreManager {
    static let shared = FirestoreManager()
    private init() {}
    
    let db = Firestore.firestore()
    
    func fetchDocument<T: Decodable>(collection: String, documentId: String, as type: T.Type) async throws -> T? {
        let snapshot = try await db.collection(collection).document(documentId).getDocument()
        return try snapshot.data(as: T.self)
    }
    
    func setDocument<T: Encodable>(collection: String, documentId: String, data: T) async throws {
        try db.collection(collection).document(documentId).setData(from: data)
    }
    
    func hasLiked(postId: String) async throws -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else {
            return false
        }

        let document = try await db
            .collection("posts")
            .document(postId)
            .collection("likes")
            .document(uid)
            .getDocument()

        return document.exists
    }
    
    func toggleLike(postId: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let postRef = db.collection("posts").document(postId)
        let likeRef = postRef.collection("likes").document(uid)

        _ = try await db.runTransaction { transaction, errorPointer in

            do {
                let likeSnapshot = try transaction.getDocument(likeRef)
                let postSnapshot = try transaction.getDocument(postRef)

                let currentLikes = postSnapshot.data()?["likeCount"] as? Int ?? 0

                if likeSnapshot.exists {
                    transaction.deleteDocument(likeRef)

                    transaction.updateData([
                        "likeCount": max(currentLikes - 1, 0)
                    ], forDocument: postRef)

                } else {
                    transaction.setData([
                        "likedAt": FieldValue.serverTimestamp()
                    ], forDocument: likeRef)

                    transaction.updateData([
                        "likeCount": currentLikes + 1
                    ], forDocument: postRef)
                }

                return nil

            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }
    }
    
    func addComment(
        postId: String,
        text: String,
        authorName: String,
    ) async throws {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let commentRef = db
            .collection("posts")
            .document(postId)
            .collection("comments")
            .document()
        
        let postRef = db
            .collection("posts")
            .document(postId)
        
        let postSnapshot = try await postRef.getDocument()
        let currentComments = postSnapshot.data()?["commentCount"] as? Int ?? 0
        
        let commentData: [String: Any] = [
            "authorId": uid,
            "authorName": authorName,
            "text": text,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        try await commentRef.setData(commentData)
        
        try await postRef.updateData([
            "commentCount": currentComments + 1
        ])
    }
    
    func fetchComments(postId: String) async throws -> [Comment] {
        let snapshot = try await db
            .collection("posts")
            .document(postId)
            .collection("comments")
            .order(by: "createdAt", descending: false)
            .getDocuments()
        
        return try snapshot.documents.compactMap {
            try $0.data(as: Comment.self)
        }
    }
}
