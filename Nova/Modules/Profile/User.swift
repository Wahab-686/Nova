//
//  User.swift
//  Nova
//
//  Created by Wahab on 04/08/2026.
//

import Foundation

struct NovaUser: Codable, Identifiable {
    var id: String
    var name: String
    var bio: String
    var profileImageURL: String?
    var creativeFocus: [String]
    var createdAt: Date
}
