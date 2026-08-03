//
//  AppleSignInButton.swift
//  Nova
//
//  Created by Wahab on 03/08/2026.
//

import SwiftUI
import AuthenticationServices
import CryptoKit

struct AppleSignInButton: UIViewRepresentable {
    var onCompletion: (Result<ASAuthorization, Error>) -> Void
    @State private var currentNonce: String?

    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(type: .continue, style: .whiteOutline)
        button.cornerRadius = 14
        button.addTarget(context.coordinator, action: #selector(Coordinator.handleTap), for: .touchUpInside)
        return button
    }

    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onCompletion: onCompletion)
    }

    class Coordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
        let onCompletion: (Result<ASAuthorization, Error>) -> Void
        var currentNonce: String?

        init(onCompletion: @escaping (Result<ASAuthorization, Error>) -> Void) {
            self.onCompletion = onCompletion
        }

        @objc func handleTap() {
            let nonce = AuthManager.shared.randomNonceString()
            currentNonce = nonce

            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = AuthManager.shared.sha256(nonce)

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }

        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            onCompletion(.success(authorization))
        }

        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            onCompletion(.failure(error))
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
}
