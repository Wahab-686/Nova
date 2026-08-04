//
//  LoginView.swift
//  Nova
//
//  Created by Wahab on 31/07/2026.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 60)
                    
                    Text("Welcome Back")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Sign in to continue creating")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Spacer().frame(height: 20)
                    
                    VStack(spacing: 16) {
                        TextField("", text: $email, prompt: Text("Email").foregroundColor(.white.opacity(0.4)))
                            .textFieldStyle(NovaTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                        
                        SecureField("", text: $password, prompt: Text("Password").foregroundColor(.white.opacity(0.4)))
                            .textFieldStyle(NovaTextFieldStyle())
                    }
                    .padding(.horizontal, 24)
                    
                    
                    HStack {
                        Spacer()
                        NavigationLink("Forgot Password?") {
                            ForgotPasswordView()
                        }
                        .font(.footnote)
                        .foregroundColor(.purple)
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
                            await viewModel.signIn(email: email, password: password)
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
                            Text("Sign In")
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
                        VStack {
                            Divider().background(Color.white.opacity(0.2))
                        }
                        Text("or")
                            .foregroundColor(.white.opacity(0.4))
                            .font(.footnote)
                        VStack {
                            Divider().background(Color.white.opacity(0.2))
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    VStack(spacing: 12) {
                        SocialLoginButton(title: "Continue with Google", icon: "globe") {
                            Task {
                                await viewModel.signInWithGoogle()
                            }
                        }
                        
                        NavigationLink {
                             PhoneEntryView()
                         } label: {
                             HStack {
                                 Image(systemName: "phone.fill")
                                 Text("Continue with Phone")
                             }
                             .font(.subheadline.bold())
                             .foregroundColor(.white)
                             .frame(maxWidth: .infinity)
                             .padding()
                             .background(Color.white.opacity(0.08))
                             .cornerRadius(14)
                         }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer().frame(height: 20)
                    
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.white.opacity(0.6))
                        NavigationLink("Sign Up") {
                            SignUpView()
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

struct NovaTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.08))
            .cornerRadius(12)
            .foregroundColor(.white)
    }
}

struct SocialLoginButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(.subheadline.bold())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white.opacity(0.08))
            .cornerRadius(14)
        }
    }
}

#Preview {
    LoginView()
}
