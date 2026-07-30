//
//  NovaApp.swift
//  Nova
//
//  Created by Wahab on 30/07/2026.
//

import SwiftUI
import FirebaseCore

@main
struct NovaApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
