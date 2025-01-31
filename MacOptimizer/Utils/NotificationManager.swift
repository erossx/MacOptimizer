import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {
        requestAuthorization()
    }
    
    private func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                Logger.shared.info("알림 권한이 승인되었습니다.")
            } else if let error = error {
                Logger.shared.error("알림 권한 요청 실패: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotification(title: String, body: String, timeInterval: TimeInterval? = nil) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger: UNNotificationTrigger
        if let interval = timeInterval {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        } else {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        }
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Logger.shared.error("알림 스케줄링 실패: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleWeeklyReport() {
        let content = UNMutableNotificationContent()
        content.title = "주간 시스템 리포트"
        content.body = "이번 주 시스템 상태와 최적화 현황을 확인해보세요."
        
        var dateComponents = DateComponents()
        dateComponents.weekday = 1  // 일요일
        dateComponents.hour = 10    // 오전 10시
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "weekly_report",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Logger.shared.error("주간 리포트 알림 스케줄링 실패: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleMonthlyReport() {
        let content = UNMutableNotificationContent()
        content.title = "월간 시스템 리포트"
        content.body = "이번 달 시스템 최적화 현황과 개선사항을 확인해보세요."
        
        var dateComponents = DateComponents()
        dateComponents.day = 1      // 매월 1일
        dateComponents.hour = 10    // 오전 10시
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "monthly_report",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Logger.shared.error("월간 리포트 알림 스케줄링 실패: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleLowDiskSpaceAlert(threshold: Double = 0.1) { // 10% 남았을 때
        let content = UNMutableNotificationContent()
        content.title = "디스크 공간 부족"
        content.body = "디스크 여유 공간이 10% 미만입니다. 디스크 정리를 실행해보세요."
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: true) // 1시간마다 체크
        
        let request = UNNotificationRequest(
            identifier: "low_disk_space",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Logger.shared.error("디스크 공간 알림 스케줄링 실패: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleHighMemoryUsageAlert(threshold: Double = 0.9) { // 90% 이상 사용 시
        let content = UNMutableNotificationContent()
        content.title = "높은 메모리 사용량"
        content.body = "메모리 사용량이 90%를 초과했습니다. 메모리 최적화를 실행해보세요."
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 300, repeats: true) // 5분마다 체크
        
        let request = UNNotificationRequest(
            identifier: "high_memory_usage",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Logger.shared.error("메모리 사용량 알림 스케줄링 실패: \(error.localizedDescription)")
            }
        }
    }
    
    func removeAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func removeAllDeliveredNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
} 