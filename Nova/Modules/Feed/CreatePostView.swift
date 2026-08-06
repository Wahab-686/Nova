//
//  CreatePostView.swift
//  Nova
//
//  Created by Wahab on 05/08/2026.
//

import SwiftUI
import PhotosUI
import FirebaseAuth

struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isPosting = false
    @State private var errorMessage: String?
    let onPosted: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.08))
                                    .frame(height: 240)
                                
                                if let selectedImage = selectedImage {
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 240)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                } else {
                                    VStack(spacing: 8) {
                                        Image(systemName: "photo.badge.plus")
                                            .font(.system(size: 36))
                                            .foregroundColor(.white.opacity(0.5))
                                        Text("Add a photo of your work")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .onChange(of: selectedItem) {
                            _, newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let image = UIImage(data: data) {
                                    selectedImage = image
                                }
                            }
                        }
                        
                        VStack(spacing: 16) {
                            TextField("", text: $title, prompt: Text("Title").foregroundColor(.white.opacity(0.4)))
                                .textFieldStyle(NovaTextFieldStyle())
                            
                            TextField("", text: $description, prompt: Text("Description").foregroundColor(.white.opacity(0.4)))
                                .textFieldStyle(NovaTextFieldStyle())
                        }
                        .padding(.horizontal, 16)
                        
                        if let error = errorMessage {
                            Text(error)
                                .font(.footnote)
                                .foregroundColor(.red)
                                .padding(.horizontal, 16)
                        }
                        Button {
                            Task {
                                await post()
                            }
                        } label: {
                            if isPosting {
                                ProgressView()
                                    .tint(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.purple)
                                    .cornerRadius(14)
                            } else {
                                Text("Post")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.purple)
                                    .cornerRadius(14)
                            }
                        }
                        .disabled(isPosting || title.isEmpty || selectedImage == nil)
                        .padding(.horizontal, 16)
                        
                        Spacer()
                    }
                    .padding(.top, 16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("New Post")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.purple)
                }
            }
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
    
    func post() async {
        isPosting = true
        errorMessage = nil
        do {
            guard let selectedImage = selectedImage else { return }
            guard let userId = AuthManager.shared.currentUser?.uid else { return }
            
            let imageURL = try await CloudinaryManager.shared.uploadImage(selectedImage)
            let userDoc: NovaUser? = try await FirestoreManager.shared.fetchDocument(collection: "users", documentId: userId, as: NovaUser.self)
            
            let post = Post(
                id: UUID().uuidString,
                authorId: userId,
                authorName: userDoc?.name ?? "Unknown",
                authorImageURL: userDoc?.profileImageURL,
                title: title,
                description: description,
                imageURL: imageURL,
                shapeColor: ["purple", "blue", "orange"].randomElement()!,
                likeCount: 0,
                commentCount: 0,
                createdAt: Date()
            )
            
            try await FirestoreManager.shared.setDocument(collection: "posts", documentId: post.id, data: post)
            onPosted()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isPosting = false
    }
}

#Preview {
    CreatePostView(onPosted: {})
}
