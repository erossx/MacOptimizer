import Foundation
import UserNotifications
import Combine
import SwiftUI
import AppKit
import ServiceManagement

class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("launchAtLogin") private var launchAtLogin: Bool = false
    @AppStorage("enableNotifications") private var enableNotifications: Bool = true
    @AppStorage("autoCleanupEnabled") private var autoCleanupEnabled: Bool = false
    @AppStorage("autoCleanupInterval") private var autoCleanupInterval: Int = 7 // 일 단위
    
    @Published var autoOptimize: Bool {
        didSet {
            UserDefaults.standard.set(autoOptimize, forKey: "autoOptimize")
            updateAutoOptimizeSchedule()
        }
    }
    
    @Published var optimizeInterval: Double {
        didSet {
            UserDefaults.standard.set(optimizeInterval, forKey: "optimizeInterval")
            updateAutoOptimizeSchedule()
        }
    }
    
    private var autoOptimizeTimer: Timer?
    
    private init() {
        // UserDefaults에서 설정 로드
        self.autoOptimize = UserDefaults.standard.bool(forKey: "autoOptimize")
        self.optimizeInterval = UserDefaults.standard.double(forKey: "optimizeInterval")
        
        // 초기 설정이 없는 경우 기본값 설정
        if optimizeInterval == 0 {
            optimizeInterval = 24.0 // 기본값 24시간
        }
        
        // 초기 설정 로드
        loadSettings()
        
        // 앱 시작 시 자동 최적화 스케줄 설정
        updateAutoOptimizeSchedule()
    }
    
    private func loadSettings() {
        // 다크 모드 상태 동기화
        isDarkMode = NSApp.effectiveAppearance.name == .darkAqua
        
        // 알림 설정 확인 및 적용
        if enableNotifications {
            NotificationManager.shared.scheduleWeeklyReport()
            NotificationManager.shared.scheduleMonthlyReport()
        }
    }
    
    private func updateAutoOptimizeSchedule() {
        autoOptimizeTimer?.invalidate()
        
        guard autoOptimize else { return }
        
        autoOptimizeTimer = Timer.scheduledTimer(withTimeInterval: optimizeInterval * 3600, repeats: true) { [weak self] _ in
            Task {
                try? await SystemOptimizer().startOptimization()
            }
        }
    }
    
    private func updateAppearance() {
        NSApp.appearance = NSAppearance(named: isDarkMode ? .darkAqua : .aqua)
    }
    
    // MARK: - Dark Mode
    
    func toggleDarkMode() {
        isDarkMode.toggle()
        updateAppearance()
    }
    
    // MARK: - Notifications
    
    func toggleNotifications() {
        enableNotifications.toggle()
        if enableNotifications {
            NotificationManager.shared.scheduleWeeklyReport()
            NotificationManager.shared.scheduleMonthlyReport()
        } else {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        }
    }
    
    // MARK: - Auto Cleanup
    
    func toggleAutoCleanup() {
        autoCleanupEnabled.toggle()
        if autoCleanupEnabled {
            scheduleAutoCleanup()
        } else {
            cancelAutoCleanup()
        }
    }
    
    func setAutoCleanupInterval(_ days: Int) {
        autoCleanupInterval = days
        if autoCleanupEnabled {
            scheduleAutoCleanup()
        }
    }
    
    private func scheduleAutoCleanup() {
        // 자동 정리 스케줄링 로직
        guard autoCleanupEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "자동 정리 예정"
        content.body = "시스템 자동 정리가 곧 시작됩니다."
        
        var dateComponents = DateComponents()
        dateComponents.hour = 2 // 새벽 2시에 실행
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "autoCleanup", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Logger.shared.error("자동 정리 알림 스케줄링 실패: \(error.localizedDescription)")
            }
        }
    }
    
    private func cancelAutoCleanup() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["autoCleanup"])
    }
    
    // MARK: - Launch at Login
    
    func toggleLaunchAtLogin() {
        launchAtLogin.toggle()
        if #available(macOS 13.0, *) {
            let service = SMAppService.mainApp
            do {
                if launchAtLogin {
                    try service.register()
                } else {
                    try service.unregister()
                }
            } catch {
                Logger.shared.error("로그인 시 자동 실행 설정 실패: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Getters
    
    var isNotificationsEnabled: Bool {
        enableNotifications
    }
    
    var isAutoCleanupEnabled: Bool {
        autoCleanupEnabled
    }
    
    var isLaunchAtLoginEnabled: Bool {
        launchAtLogin
    }
    
    var currentAutoCleanupInterval: Int {
        autoCleanupInterval
    }
} 
