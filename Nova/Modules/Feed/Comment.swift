//
//  Comment.swift
//  Nova
//
//  Created by Wahab on 08/08/2026.
//

import Foundation
import FirebaseFirestore

struct Comment: Identifiable, Codable {
    @DocumentID var id: String?
    
    let authorId: String
    let authorName: String
    let text: String
    let createdAt: Date
}
