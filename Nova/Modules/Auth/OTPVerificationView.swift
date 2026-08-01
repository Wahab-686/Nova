//
//  OTPVerificationView.swift
//  Nova
//
//  Created by Wahab on 01/08/2026.
//

import SwiftUI

struct OTPVerificationView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var code = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer().frame(height: 60)

                Text("Enter Code")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("We sent a 6-digit code to your phone")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))

                TextField("", text: $code, prompt: Text("123456").foregroundColor(.white.opacity(0.4)))
                    .textFieldStyle(NovaTextFieldStyle())
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.title2)
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
                        await viewModel.verifyOTP(code: code)
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
                        Text("Verify")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(14)
                    }
                }
                .disabled(viewModel.isLoading || code.isEmpty)
                .padding(.horizontal, 24)

                Spacer()
            }
        }
    }
}
