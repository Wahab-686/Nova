//
//  RootView.swift
//  Nova
//
//  Created by Wahab on 31/07/2026.
//

import SwiftUI

struct RootView: View {
    @State private var showSplash = true
    @State private var onboardingComplete = false

    var body: some View {
        if showSplash {
            SplashView()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            showSplash = false
                        }
                    }
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
