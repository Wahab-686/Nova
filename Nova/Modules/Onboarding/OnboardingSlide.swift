//
//  OnboardingSlide.swift
//  Nova
//
//  Created by Wahab on 31/07/2026.
//

import Foundation

struct OnboardingSlide: Identifiable {
    let id = UUID()
    let title: String
    let subTitle: String
    let shapeColor: String
}

let onboardingSlides: [OnboardingSlide] = [
    OnboardingSlide(title: "Create in 3D",
                    subTitle: "Showcase your work like never before — objects that move, rotate, and come alive.",
                    shapeColor: "purple"
                   ),
    OnboardingSlide(title: "Connect with Creators",
                    subTitle: "Chat, call, and collaborate with artists and designers around the world.",
                    shapeColor: "blue"
                   ),
    OnboardingSlide(title: "AI-Powered Feedback",
                    subTitle: "Get instant creative feedback from your built-in AI assistant.",
                    shapeColor: "orange"
                   )
]
