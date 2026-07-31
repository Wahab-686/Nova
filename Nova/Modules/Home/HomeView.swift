//
//  HomeView.swift
//  Nova
//
//  Created by Wahab on 31/07/2026.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                Text("You're logged in!")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                Text("Home feed coming in Phase 4")
                    .foregroundColor(.white.opacity(0.6))

                Button("Sign Out (testing only)") {
                    try? AuthManager.shared.signOut()
                }
                .foregroundColor(.red)
                .padding(.top, 20)
            }
        }
    }
}
