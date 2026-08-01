//
//  EmailVerificationView.swift
//  Nova
//
//  Created by Wahab on 01/08/2026.
//

import SwiftUI

struct EmailVerificationView: View {
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "envelope.badge.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.purple)

                Text("Verify Your Email")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("We sent a verification link to your email. Please check your inbox and tap the link to continue.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .padding(.horizontal, 24)
                }

                Button {
                    Task {
                        await viewModel.checkEmailVerification()
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
                        Text("I've Verified My Email")
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

                Button {
                    Task {
                        await viewModel.resendVerificationEmail()
                    }
                } label: {
                    Text("Resend Email")
                        .font(.footnote)
                        .foregroundColor(.purple)
                }

                Spacer()
            }
        }
    }
}

#Preview {
    EmailVerificationView()
}
