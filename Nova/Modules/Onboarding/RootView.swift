//
//  RootView.swift
//  Nova
//
//  Created by Wahab on 31/07/2026.
//

import SwiftUI

struct RootView: View {
    @State private var showSplash = true

    var body: some View {
        if showSplash {
            SplashView()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                        withAnimation {
                            showSplash = false
                        }
                    }
                }
        } else {
            OnboardingView()
        }
    }
}
