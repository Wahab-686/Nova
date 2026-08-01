//
//  NovaApp.swift
//  Nova
//
//  Created by Wahab on 30/07/2026.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }

    func application(_ application: UIApplication,
                      didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Auth.auth().setAPNSToken(deviceToken, type: .unknown) 
    }

    func application(_ application: UIApplication,
                      didReceiveRemoteNotification notification: [AnyHashable: Any],
                      fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(.noData)
            return
        }
        completionHandler(.newData)
    }
}

@main
struct NovaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
                .onOpenURL { url in
                    _ = Auth.auth().canHandle(url)
                }
                .onAppear {
                    UIApplication.shared.registerForRemoteNotifications()
                }
        }
    }
}
