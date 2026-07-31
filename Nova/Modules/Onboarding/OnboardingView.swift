//
//  OnboardingView.swift
//  Nova
//
//  Created by Wahab on 31/07/2026.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    let onFinish: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                ForEach(Array(onboardingSlides.enumerated()), id: \.element.id) {
                    index, slide in
                    OnboardingSlideView(slide: slide)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            VStack {
                Spacer()
                if currentPage == onboardingSlides.count - 1 {
                    Button(action: onFinish) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 70)
                    .transition(.opacity)
                }
            }
        }
    }
}

struct OnboardingSlideView: View {
    let slide: OnboardingSlide
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Circle()
                .fill(colorFor(slide.shapeColor))
                .frame(width: 160, height: 160)
                .shadow(color: colorFor(slide.shapeColor).opacity(0.6), radius: 30)
            
            Spacer()
            
            Text(slide.title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(slide.subTitle)
                .font(.body)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            Spacer()
        }
    }
    
    func colorFor(_ name: String) -> Color {
        switch name {
        case "purple": return .purple
        case "blue": return .blue
        case "orange": return .orange
        default: return .white
        }
    }
}

#Preview {
    OnboardingView(onFinish: {})
}
