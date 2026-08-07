//
//  PostDetailView.swift
//  Nova
//
//  Created by Wahab on 06/08/2026.
//

import SwiftUI

struct PostDetailView: View {
    let post: Post
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    RetryableAsyncImage(url: URL(string: post.imageURL)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 400)
                            .overlay(ProgressView().tint(.white))
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            RetryableAsyncImage(url: URL(string: post.authorImageURL ?? "")) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            } placeholder: {
                                Circle()
                                    .fill(colorFor(post.shapeColor).opacity(0.3))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Text(String(post.authorName.prefix(1)).uppercased())
                                            .font(.subheadline.bold())
                                            .foregroundColor(colorFor(post.shapeColor))
                                    )
                            }
                            VStack(alignment: .leading) {
                                Text(post.authorName)
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                                Text(post.createdAt.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            Spacer()
                        }

                        Text(post.title)
                            .font(.title2.bold())
                            .foregroundColor(.white)

                        if !post.description.isEmpty {
                            Text(post.description)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                        }

                        HStack(spacing: 24) {
                            Label("\(post.likeCount)", systemImage: "heart")
                            Label("\(post.commentCount)", systemImage: "bubble.right")
                        }
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.black, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    func colorFor(_ name: String) -> Color {
        switch name {
        case "purple": return .purple
        case "blue": return .blue
        case "orange": return .orange
        default: return .white
        }
    }
}

#Preview {
    NavigationStack {
        PostDetailView(post: Post(
            id: "1",
            authorId: "1",
            authorName: "Wahab",
            authorImageURL: nil,
            title: "My First 3D Sculpture",
            description: "A beautiful sculpture made with love",
            imageURL: "https://picsum.photos/400/300",
            shapeColor: "purple",
            likeCount: 12,
            commentCount: 3,
            createdAt: Date()
        ))
    }
}
