import XCTest
@testable import MacOptimizer

class OptimizationFlowTests: XCTestCase {
    var systemMonitor: SystemMonitor!
    var optimizer: SystemOptimizer!
    var notificationManager: NotificationManager!
    
    override func setUp() {
        super.setUp()
        systemMonitor = SystemMonitor()
        optimizer = SystemOptimizer()
        notificationManager = NotificationManager.shared
    }
    
    override func tearDown() {
        systemMonitor.stopMonitoring()
        systemMonitor = nil
        optimizer = nil
        super.tearDown()
    }
    
    func testCompleteOptimizationFlow() async throws {
        // 1. 시스템 모니터링 시작
        systemMonitor.startMonitoring()
        
        // 초기 시스템 상태 기록
        let initialCPUUsage = systemMonitor.cpuUsage
        let initialMemoryUsage = systemMonitor.memoryUsage.used
        let initialDiskUsage = systemMonitor.diskUsage.used
        
        // 2. 최적화 실행
        try await optimizer.startOptimization()
        
        // 3. 최적화 후 시스템 상태 확인
        XCTAssertLessThanOrEqual(systemMonitor.memoryUsage.used, initialMemoryUsage)
        XCTAssertLessThanOrEqual(systemMonitor.diskUsage.used, initialDiskUsage)
        
        // 4. 알림 확인
        let expectation = XCTestExpectation(description: "Optimization completion notification")
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            XCTAssertTrue(requests.contains { request in
                request.content.title.contains("최적화 완료")
            })
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
} 