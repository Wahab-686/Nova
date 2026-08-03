//
//  AuthViewModel.swift
//  Nova
//
//  Created by Wahab on 31/07/2026.
//

import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    @Published var resetEmailSent = false
    @Published var needsEmailVerification = false
    @Published var isEmailVerified = false
    @Published var otpSent = false
    
    func signUp(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await AuthManager.shared.signUp(email: email, password: password)
            try await AuthManager.shared.sendEmailVerification()
            needsEmailVerification = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await AuthManager.shared.signIn(email: email, password: password)
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func sendPasswordReset(email: String) async {
        isLoading = true
        errorMessage = nil
        resetEmailSent = false
        
        do {
            try await AuthManager.shared.sendPasswordReset(email: email)
            resetEmailSent = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func checkEmailVerification() async {
        isLoading = true
        do {
            let verified = try await AuthManager.shared.reloadUser()
            isEmailVerified = verified
            if verified {
                isAuthenticated = true
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func resendVerificationEmail() async {
        do {
            try await AuthManager.shared.sendEmailVerification()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func sendOTP(phoneNumber: String) async {
        isLoading = true
        errorMessage = nil
        do {
            try await AuthManager.shared.sendOTP(phoneNumber: phoneNumber)
            otpSent = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func verifyOTP(code: String) async {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await AuthManager.shared.verifyOTP(code: code)
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await AuthManager.shared.signInWithGoogle()
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
