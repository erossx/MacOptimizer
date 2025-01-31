import XCTest
@testable import MacOptimizer

class NotificationManagerTests: XCTestCase {
    var notificationManager: NotificationManager!
    
    override func setUp() {
        super.setUp()
        notificationManager = NotificationManager.shared
    }
    
    func testScheduleNotification() {
        let expectation = XCTestExpectation(description: "Notification scheduled")
        
        notificationManager.scheduleNotification(
            title: "Test Title",
            body: "Test Body"
        )
        
        // 알림 센터에서 예약된 알림 확인
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            XCTAssertTrue(requests.contains { request in
                request.content.title == "Test Title" &&
                request.content.body == "Test Body"
            })
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testCancelNotifications() {
        let expectation = XCTestExpectation(description: "Notifications cancelled")
        
        // 먼저 알림 예약
        notificationManager.scheduleNotification(title: "Test", body: "Test")
        
        // 알림 취소
        notificationManager.cancelAllNotifications()
        
        // 예약된 알림이 없는지 확인
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            XCTAssertTrue(requests.isEmpty)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
} 