//
//  ForgotPasswordView.swift
//  Nova
//
//  Created by Wahab on 01/08/2026.
//

import SwiftUI

struct ForgotPasswordView: View {
    @State private var email = ""
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 14) {
                Spacer().frame(height: 60)
                
                Text("Reset Password")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Enter your email and we'll send you a link to reset your password.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                if viewModel.resetEmailSent {
                    VStack(spacing: 12) {
                        Image(systemName: "envelope.badge.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                        
                        Text("Check your inbox")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("We sent a reset link to \(email)")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                } else {
                    TextField("", text: $email, prompt: Text("Email").foregroundColor(.white.opacity(0.4)))
                        .textFieldStyle(NovaTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .padding(.horizontal, 24)
                    }
                    
                    Button {
                        Task {
                            await viewModel.sendPasswordReset(email: email)
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
                            Text("Send Reset Link")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .cornerRadius(14)
                        }
                    }
                    .disabled(viewModel.isLoading || email.isEmpty)
                    .padding(.horizontal, 24)
                }
                Spacer()
            }
        }
    }
}

#Preview {
    ForgotPasswordView()
}
