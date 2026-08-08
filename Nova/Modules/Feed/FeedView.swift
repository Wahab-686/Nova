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
                                NavigationLink {
                                    PostDetailView(post: post)
                                } label: {
                                    FeedPostCard(post: post, containerHeight: outerGeo.size.height, onCommentAdded: {
                                        Task {
                                            await viewModel.fetchPosts()
                                        }
                                    })
                                }
                                .buttonStyle(.plain)
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
    let onCommentAdded: () -> Void
    
    @State private var isLiked = false
    @State private var likeCount: Int
    @State private var showComments = false
    
    init(post: Post, containerHeight: CGFloat, onCommentAdded: @escaping () -> Void) {
        self.post = post
        self.containerHeight = containerHeight
        self.onCommentAdded = onCommentAdded
        _likeCount = State(initialValue: post.likeCount)
    }

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
                RetryableAsyncImage(url: URL(string: post.authorImageURL ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                } placeholder: {
                    Circle()
                        .fill(colorFor(post.shapeColor).opacity(0.3))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text(String(post.authorName.prefix(1)).uppercased())
                                .font(.footnote.bold())
                                .foregroundColor(colorFor(post.shapeColor))
                        )
                }
                Text(post.authorName)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                Spacer()
            }

            RetryableAsyncImage(url: URL(string: post.imageURL)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } placeholder: {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 240)
                    .overlay(ProgressView().tint(.white))
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
                Button {
                    Task {
                        do {
                            try await FirestoreManager.shared.toggleLike(postId: post.id)
                            print("Like toggled for:", post.id)
                            if isLiked {
                                likeCount = max(likeCount - 1, 0)
                            } else {
                                likeCount += 1
                            }
                            
                            isLiked.toggle()
                            
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                } label: {
                    Label(
                        "\(likeCount)",
                        systemImage: isLiked ? "heart.fill" : "heart"
                    )
                    .foregroundColor(isLiked ? .red : .white.opacity(0.6))
                }
                
                Button {
                    print("COMMENT BUTTON:", post.id)
                    showComments = true
                } label: {
                    Label("\(post.commentCount)", systemImage: "bubble.right")
                        .foregroundColor(.white)
                        .padding(8)
                }
                .contentShape(Rectangle())
                
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
        .contentShape(RoundedRectangle(cornerRadius: 20))
        .sheet(isPresented: $showComments) {
            PostCommentsView(postId: post.id,
                             onCommentAdded: onCommentAdded)
                .presentationDetents([.medium])
        }
        
        .task {
            do {
                isLiked = try await FirestoreManager.shared.hasLiked(postId: post.id)
            } catch {
                print(error.localizedDescription)
            }
        }
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
        FeedPostCard(
            post: Post(
                id: "1",
                authorId: "1",
                authorName: "Wahab",
                authorImageURL: nil,
                title: "My First 3D Sculpture",
                description: "Testing the feed with a sample post",
                imageURL: "https://picsum.photos/400/300",
                shapeColor: "purple",
                likeCount: 12,
                commentCount: 3,
                createdAt: Date()
            ),
            containerHeight: 800,
            onCommentAdded: {}
        )
    }
    .padding()
}
