//
//  PhoneEntryView.swift
//  Nova
//
//  Created by Wahab on 01/08/2026.
//

import SwiftUI

struct PhoneEntryView: View {
    @State private var phoneNumber = ""
    @StateObject private var viewModel = AuthViewModel()
    @State private var navigateToOTP = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer().frame(height: 60)

                Text("Enter Your Number")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("We'll send you a verification code")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))

                TextField("", text: $phoneNumber, prompt: Text("+1 650 555 3434").foregroundColor(.white.opacity(0.4)))
                    .textFieldStyle(NovaTextFieldStyle())
                    .keyboardType(.phonePad)
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
                        await viewModel.sendOTP(phoneNumber: phoneNumber)
                        if viewModel.otpSent {
                            navigateToOTP = true
                        }
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
                        Text("Send Code")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(14)
                    }
                }
                .disabled(viewModel.isLoading || phoneNumber.isEmpty)
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .navigationDestination(isPresented: $navigateToOTP) {
            OTPVerificationView(viewModel: viewModel)
        }
    }
}

#Preview {
    NavigationStack {
        PhoneEntryView()
    }
}
