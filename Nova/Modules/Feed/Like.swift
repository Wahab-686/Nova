//
//  Like.swift
//  Nova
//
//  Created by Wahab on 07/08/2026.
//

import Foundation
import FirebaseFirestore

struct Like: Codable {
    @DocumentID var id: String?
    let likedAt: Date
}
