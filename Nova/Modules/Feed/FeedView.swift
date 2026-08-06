//
//  FeedView.swift
//  Nova
//
//  Created by Wahab on 04/08/2026.
//

import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @State private var showCreatePost = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if viewModel.isLoading && viewModel.posts.isEmpty {
                ProgressView()
                    .tint(.white)
            } else if viewModel.posts.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.3))
                    Text("No posts yet")
                        .foregroundColor(.white.opacity(0.6))
                    Text("Be the first to share your work")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.4))
                }
            } else {
                GeometryReader { outerGeo in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.posts) { post in
                                FeedPostCard(post: post, containerHeight: outerGeo.size.height)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showCreatePost = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.purple)
                }
            }
        }
        .sheet(isPresented: $showCreatePost) {
            CreatePostView {
                Task { await viewModel.fetchPosts() }
            }
        }
        .task {
            await viewModel.fetchPosts()
        }
    }
}

struct FeedPostCard: View {
    let post: Post
    let containerHeight: CGFloat

    var body: some View {
        GeometryReader { geo in
            let midY = geo.frame(in: .global).midY
            let distanceFromCenter = midY - containerHeight / 2
            let normalizedDistance = distanceFromCenter / (containerHeight / 2)

            let scale = 1.0 - min(abs(normalizedDistance) * 0.15, 0.15)
            let rotation = normalizedDistance * 6

            cardContent
                .scaleEffect(scale)
                .rotation3DEffect(
                    .degrees(rotation),
                    axis: (x: 1, y: 0, z: 0),
                    perspective: 0.5
                )
        }
        .frame(height: 380)
    }

    var cardContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(colorFor(post.shapeColor))
                    .frame(width: 32, height: 32)
                Text(post.authorName)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                Spacer()
            }

            AsyncImage(url: URL(string: post.imageURL)) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 240)
                        .overlay(ProgressView().tint(.white))
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                case .failure:
                    RoundedRectangle(cornerRadius: 16)
                        .frame(height: 240)
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                Text("Image failed to load")
                                    .font(.footnote)
                                    .foregroundColor(.white)
                            }
                        )
                @unknown default:
                    EmptyView()
                }
            }

            Text(post.title)
                .font(.headline)
                .foregroundColor(.white)

            if !post.description.isEmpty {
                Text(post.description)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }

            HStack(spacing: 16) {
                Label("\(post.likeCount)", systemImage: "heart")
                Label("\(post.commentCount)", systemImage: "bubble.right")
                Spacer()
                Text(post.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
            .font(.footnote)
            .foregroundColor(.white.opacity(0.6))
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
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
        FeedView()
    }
}
