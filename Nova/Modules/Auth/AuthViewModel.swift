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
    
    func signUp(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await AuthManager.shared.signUp(email: email, password: password)
            isAuthenticated = true
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
}
