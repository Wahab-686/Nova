//
//   FirestoreManager.swift
//  Nova
//
//  Created by Wahab on 30/07/2026.
//

import Foundation
import FirebaseFirestore

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
}
