//
//  RootView.swift
//  Nova
//
//  Created by Wahab on 31/07/2026.
//

import SwiftUI
import FirebaseAuth
 
struct RootView: View {
    @State private var showSplash = true
    @State private var onboardingComplete = false
    @StateObject private var authManager = AuthManager.shared
 
    var body: some View {
        Group {
            if showSplash {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else if authManager.isLoggedIn {
                if authManager.isEmailVerified {
                    HomeView()
                } else {
                    EmailVerificationView()
                }
            } else if !onboardingComplete {
                OnboardingView(onFinish: {
                    withAnimation {
                        onboardingComplete = true
                    }
                })
            } else {
                NavigationStack {
                    LoginView()
                }
            }
        }
    }
}
 
#Preview {
    RootView()
}
 
