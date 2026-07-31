//
//  SplashView.swift
//  Nova
//
//  Created by Wahab on 31/07/2026.
//

import SwiftUI

struct SplashView: View {
    @State private var showText = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            SplashSceneView()
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                if showText {
                    Text("Nova")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .transition(.opacity)
                }
                Spacer().frame(height: 80)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 1.0).delay(1.5)) {
                showText = true
            }
        }
    }
}

#Preview {
    SplashView()
}
