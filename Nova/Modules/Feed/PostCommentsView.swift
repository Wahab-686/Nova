//
//  PostCommentsView.swift
//  Nova
//
//  Created by Wahab on 08/08/2026.
//

import SwiftUI

struct PostCommentsView: View {
    let postId: String
    let onCommentAdded: () -> Void

    @State private var comments: [Comment] = []
    @State private var commentText = ""
    @State private var isLoading = true

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)

                } else if comments.isEmpty {
                    Text("No comments yet")
                        .foregroundColor(.white.opacity(0.6))

                } else {
                    List(comments) { comment in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(comment.authorName)
                                .font(.headline)
                                .foregroundColor(.white)

                            Text(comment.text)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .listRowBackground(Color.white.opacity(0.05))
                    }
                    .scrollContentBackground(.hidden)
                }

                HStack {
                    TextField(
                        "",
                        text: $commentText,
                        prompt: Text("Write a comment...")
                            .foregroundColor(.white.opacity(0.4))
                    )
                    .textFieldStyle(NovaTextFieldStyle())

                    Button("Send") {
                        Task {
                            await addComment()
                        }
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(14)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 8)
            }
        }
        .task {
            await loadComments()
        }
    }

    private func loadComments() async {
        do {
            comments = try await FirestoreManager.shared.fetchComments(
                postId: postId
            )
            isLoading = false
        } catch {
            print(error.localizedDescription)
            isLoading = false
        }
    }

    private func addComment() async {
        let text = commentText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !text.isEmpty else {
            return
        }

        do {
            try await FirestoreManager.shared.addComment(
                postId: postId,
                text: text,
                authorName: "Wahab"
            )

            commentText = ""

            comments = try await FirestoreManager.shared.fetchComments(
                postId: postId
            )
            onCommentAdded()

        } catch {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    PostCommentsView(postId: "preview-post-id", onCommentAdded: {})
}

