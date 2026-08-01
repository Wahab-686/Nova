//
//  AuthManager.swift
//  Nova
//
//  Created by Wahab on 30/07/2026.
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
final class AuthManager: ObservableObject {
    static let shared = AuthManager()
    private init() {
        self.isLoggedIn = Auth.auth().currentUser != nil
    }
    
    @Published var isLoggedIn: Bool
    @Published var isEmailVerified: Bool = Auth.auth().currentUser?.isEmailVerified ?? false
    
    var currentUser: FirebaseAuth.User? {
        Auth.auth().currentUser
    }
    
    func signUp(email: String, password: String) async throws -> FirebaseAuth.User {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        isLoggedIn = true
        isEmailVerified = result.user.isEmailVerified
        return result.user
    }
    
    func signIn(email: String, password: String) async throws -> FirebaseAuth.User {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        isLoggedIn = true
        isEmailVerified = result.user.isEmailVerified
        return result.user
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        isLoggedIn = false
    }
    
    func sendPasswordReset(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func sendEmailVerification() async throws {
        guard let user = Auth.auth().currentUser else { return }
        try await user.sendEmailVerification()
    }
    
    func reloadUser() async throws -> Bool {
        guard let user = Auth.auth().currentUser else { return false }
        try await user.reload()
        isEmailVerified = user.isEmailVerified
        return user.isEmailVerified
    }
}
