//
//  Post.swift
//  Nova
//
//  Created by Wahab on 04/08/2026.
//

import Foundation

struct Post: Codable, Identifiable {
    var id: String
    var authorId: String
    var authorName: String
    var authorImageURL: String?
    var title: String
    var description: String
    var imageURL: String
    var shapeColor: String
    var likeCount: Int
    var commentCount: Int
    var createdAt: Date
}
