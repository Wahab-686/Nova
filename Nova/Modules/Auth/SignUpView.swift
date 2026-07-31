//
//  SignUpView.swift
//  Nova
//
//  Created by Wahab on 31/07/2026.
//

import SwiftUI

struct SignUpView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 60)
                    
                    Text("Create Account")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Join the creative community")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Spacer().frame(height: 20)
                    
                    VStack(spacing: 16) {
                        TextField("", text: $name, prompt: Text("Full Name").foregroundColor(.white.opacity(0.4)))
                            .textFieldStyle(NovaTextFieldStyle())
                        
                        TextField("", text: $email, prompt: Text("Email").foregroundColor(.white.opacity(0.4)))
                            .textFieldStyle(NovaTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                        
                        SecureField("", text: $password, prompt: Text("Password").foregroundColor(.white.opacity(0.4)))
                            .textFieldStyle(NovaTextFieldStyle())
                    }
                    .padding(.horizontal, 24)
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .padding(.horizontal, 24)
                    }
                    
                    Button {
                        Task {
                            await viewModel.signUp(email: email, password: password)
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .cornerRadius(14)
                        } else {
                            Text("Sign Up")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .cornerRadius(14)
                        }
                    }
                    .disabled(viewModel.isLoading)
                    .padding(.horizontal, 24)
                    
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(.white.opacity(0.6))
                        NavigationLink("Sign In") {
                            LoginView()
                        }
                        .foregroundColor(.purple)
                    }
                    .font(.footnote)
                    
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    SignUpView()
}
