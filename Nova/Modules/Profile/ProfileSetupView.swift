//
//  ProfileSetupView.swift
//  Nova
//
//  Created by Wahab on 04/08/2026.
//

import SwiftUI
import PhotosUI
import FirebaseAuth

struct ProfileSetupView: View {
    @State private var name = ""
    @State private var bio = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var profileImage: UIImage?
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 40)
                    
                    Text("Set Up Your Profile")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.08))
                                .frame(width: 120, height: 120)
                            
                            if let profileImage = profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                    }
                    .onChange(of: selectedItem) {
                        _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                profileImage = image
                            }
                        }
                    }
                    
                    VStack(spacing: 16) {
                        TextField("", text: $name, prompt: Text("Full Name").foregroundColor(.white.opacity(0.4)))
                            .textFieldStyle(NovaTextFieldStyle())
                        
                        TextField("", text: $bio, prompt: Text("Bio").foregroundColor(.white.opacity(0.4)))
                            .textFieldStyle(NovaTextFieldStyle())
                    }
                    .padding(.horizontal, 24)
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .padding(.horizontal, 24)
                    }
                    
                    Button {
                        Task { await saveProfile() }
                    } label : {
                        if isSaving {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .cornerRadius(14)
                        } else {
                            Text("Continue")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .cornerRadius(14)
                        }
                    }
                    .disabled(isSaving || name.isEmpty)
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
            }
        }
    }
    
    func saveProfile() async {
        isSaving = true
        errorMessage = nil
        
        do {
            var imageURL: String? = nil
            if let profileImage = profileImage {
                imageURL = try await CloudinaryManager.shared.uploadImage(profileImage)
            }
            
            guard let userId = AuthManager.shared.currentUser?.uid else { return }
            
            let user = NovaUser(
                id: userId,
                name: name,
                bio: bio,
                profileImageURL: imageURL,
                creativeFocus: [],
                createdAt: Date()
            )
            
            try await FirestoreManager.shared.setDocument(collection: "users", documentId: userId, data: user)
            AuthManager.shared.hasProfile = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isSaving = false
    }
}

#Preview {
    ProfileSetupView()
}
