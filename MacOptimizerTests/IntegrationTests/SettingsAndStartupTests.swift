import XCTest
@testable import MacOptimizer

class SettingsAndStartupTests: XCTestCase {
    var settings: AppSettings!
    var startupManager: StartupManager!
    
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        settings = AppSettings.shared
        startupManager = StartupManager()
    }
    
    func testAutoOptimizeWithStartupItems() async throws {
        // 1. 자동 최적화 설정
        settings.autoOptimize = true
        settings.optimizeInterval = 1.0 // 테스트를 위해 1시간으로 설정
        
        // 2. 시작 프로그램 로드 및 변경
        startupManager.loadStartupItems()
        if let firstItem = startupManager.startupItems.first {
            startupManager.toggleStartupItem(firstItem)
        }
        
        // 3. 자동 최적화 실행 확인
        let expectation = XCTestExpectation(description: "Auto optimization executed")
        
        // 최적화 완료 알림 확인
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                XCTAssertTrue(requests.contains { request in
                    request.content.title.contains("최적화")
                })
                expectation.fulfill()
            }
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
} 