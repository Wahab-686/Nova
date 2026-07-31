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
    
    var currentUser: FirebaseAuth.User? {
        Auth.auth().currentUser
    }
    
    func signUp(email: String, password: String) async throws -> FirebaseAuth.User {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        isLoggedIn = true
        return result.user
    }
    
    func signIn(email: String, password: String) async throws -> FirebaseAuth.User {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        isLoggedIn = true
        return result.user
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        isLoggedIn = false
    }
    
    func sendPasswordReset(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
}
