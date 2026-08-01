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
    @Published var verificationID: String?
    
    var currentUser: FirebaseAuth.User? {
        Auth.auth().currentUser
    }
    
    var needsEmailVerification: Bool {
        guard let user = Auth.auth().currentUser, user.email != nil else { return false }
        return !user.isEmailVerified
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
    
    func sendOTP(phoneNumber: String) async throws {
        let id = try await PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil)
        verificationID = id
    }
    
    func verifyOTP(code: String) async throws -> FirebaseAuth.User {
        guard let verificationID = verificationID else {
            throw NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No verification ID found. Please request OTP again."])
        }
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: code)
        let result = try await Auth.auth().signIn(with: credential)
        isLoggedIn = true
        isEmailVerified = result.user.isEmailVerified 
        return result.user
    }
}
