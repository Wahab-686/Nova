//
//  AuthManager.swift
//  Nova
//
//  Created by Wahab on 30/07/2026.
//

import Foundation
import FirebaseAuth
import Combine
import GoogleSignIn
import FirebaseCore
import AuthenticationServices
import CryptoKit

@MainActor
final class AuthManager: ObservableObject {
    static let shared = AuthManager()
    private init() {
        self.isLoggedIn = Auth.auth().currentUser != nil
    }
    
    @Published var isLoggedIn: Bool
    @Published var isEmailVerified: Bool = Auth.auth().currentUser?.isEmailVerified ?? false
    @Published var verificationID: String?
    @Published var hasProfile: Bool = false
    var currentNonce: String?
    private var appleDelegateHandler: AppleSignInDelegateHandler?
    
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
    
    func signInWithGoogle() async throws -> FirebaseAuth.User {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing Firebase client ID"])
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not find root view controller"])
        }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)

        guard let idToken = result.user.idToken?.tokenString else {
            throw NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing ID token from Google"])
        }

        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: result.user.accessToken.tokenString)
        let authResult = try await Auth.auth().signIn(with: credential)
        isLoggedIn = true
        isEmailVerified = authResult.user.isEmailVerified
        return authResult.user
    }
    
    func signInWithApple(idTokenString: String, nonce: String, fullName: PersonNameComponents?) async throws -> FirebaseAuth.User {
        let credential = OAuthProvider.credential(providerID: .apple, idToken: idTokenString, rawNonce: nonce)
        let authResult = try await Auth.auth().signIn(with: credential)
        
        if let fullName = fullName {
            let changeRequest = authResult.user.createProfileChangeRequest()
            let displayName = [fullName.givenName, fullName.familyName].compactMap { $0 }.joined(separator: " ")
            if !displayName.isEmpty {
                changeRequest.displayName = displayName
                try? await changeRequest.commitChanges()
            }
        }
        
        isLoggedIn = true
        isEmailVerified = true
        return authResult.user
    }
    
    func checkUserProfile() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            hasProfile = false
            return
        }
        do {
            let user: NovaUser? = try await FirestoreManager.shared.fetchDocument(collection: "users", documentId: userId, as: NovaUser.self)
            hasProfile = user != nil
        } catch {
            hasProfile = false
        }
    }
    
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce.")
        }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map {
            byte in
            charset[Int(byte) % charset.count]
        }
        return String(nonce)
    }
    
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    func signInWithApple() async throws -> FirebaseAuth.User {
        let nonce = randomNonceString()
        currentNonce = nonce

        let authorization: ASAuthorization = try await withCheckedThrowingContinuation { continuation in
            let handler = AppleSignInDelegateHandler(continuation: continuation)
            self.appleDelegateHandler = handler

            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = handler
            controller.presentationContextProvider = handler
            controller.performRequests()
        }

        appleDelegateHandler = nil

        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Apple sign-in failed to produce a valid token"])
        }

        return try await signInWithApple(
            idTokenString: idTokenString,
            nonce: nonce,
            fullName: appleIDCredential.fullName
        )
    }
}

private final class AppleSignInDelegateHandler: NSObject,
    ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    private let continuation: CheckedContinuation<ASAuthorization, Error>

    init(continuation: CheckedContinuation<ASAuthorization, Error>) {
        self.continuation = continuation
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        continuation.resume(returning: authorization)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation.resume(throwing: error)
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first else {
            fatalError("No window scene found")
        }
        return windowScene.windows.first ?? ASPresentationAnchor(windowScene: windowScene)
    }
}
