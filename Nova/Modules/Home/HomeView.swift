//
//  HomeView.swift
//  Nova
//
//  Created by Wahab on 31/07/2026.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            FeedView()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Nova")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .toolbarBackground(.black, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}
