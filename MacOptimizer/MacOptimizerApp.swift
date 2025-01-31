//
//  MacOptimizerApp.swift
//  MacOptimizer
//
//  Created by 이은환 on 2/1/25.
//

import SwiftUI
import UserNotifications

@main
struct MacOptimizerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var settings = AppSettings.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(settings.darkMode ? .dark : .light)
        }
        .windowStyle(.hiddenTitleBar) // 모던한 UI를 위해 타이틀바 숨김
        .windowToolbarStyle(.unified)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().delegate = self
        
        // 알림 매니저 초기화
        _ = NotificationManager.shared
        
        // 설정 매니저 초기화
        _ = AppSettings.shared
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
