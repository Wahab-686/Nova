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
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
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
                if authManager.needsEmailVerification {
                    EmailVerificationView()
                } else if !authManager.hasProfile {
                    ProfileSetupView()
                }
                else {
                    HomeView()
                }
            } else if !hasSeenOnboarding {
                OnboardingView(onFinish: {
                    withAnimation {
                        hasSeenOnboarding = true
                    }
                })
            } else {
                NavigationStack {
                    LoginView()
                }
            }
        }
        .task {
            if authManager.isLoggedIn {
                await authManager.checkUserProfile()
            }
        }
    }
}
 
#Preview {
    RootView()
}
 
