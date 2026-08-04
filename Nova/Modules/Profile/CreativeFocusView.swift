//
//  CreativeFocusView.swift
//  Nova
//
//  Created by Wahab on 04/08/2026.
//

import SwiftUI
import FirebaseFirestoreInternal
import FirebaseAuth

struct CreativeFocusView: View {
    @State private var selectedOptions: Set<String> = []
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    let columns = [GridItem(.adaptive(minimum: 140), spacing: 12)]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer().frame(height: 40)
                
                Text("What do you create?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Pick a few that describe your work")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(creativeFocusOptions, id: \.self) {
                            option in
                            ChipView(
                                title: option,
                                isSelected: selectedOptions.contains(option)
                            ) {
                                if selectedOptions.contains(option) {
                                    selectedOptions.remove(option)
                                } else {
                                    selectedOptions.insert(option)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                }
                
                if let error = errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .padding(.horizontal, 24)
                }
                
                Button {
                    Task { await saveFocus() }
                } label: {
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
                .disabled(isSaving || selectedOptions.isEmpty)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
    }
    
    func saveFocus() async {
        isSaving = true
        errorMessage = nil
        
        do {
            guard let userId = AuthManager.shared.currentUser?.uid else { return }
            try await FirestoreManager.shared.db.collection("users").document(userId).updateData([
                "creativeFocus": Array(selectedOptions)
            ])
            AuthManager.shared.hasProfile = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isSaving = false
    }
}

struct ChipView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.purple : Color.white.opacity(0.08))
                .cornerRadius(20)
        }
    }
}

#Preview {
    CreativeFocusView()
}
