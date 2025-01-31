import XCTest
@testable import MacOptimizer

class DetailedPerformanceTests: XCTestCase {
    func testMemoryLeaks() {
        // 메모리 누수 테스트
        addTeardownBlock { [weak self] in
            XCTAssertNil(self, "Memory leak detected")
        }
    }
    
    func testCPUUsage() {
        let monitor = SystemMonitor()
        
        measure(metrics: [XCTCPUMetric()]) {
            for _ in 0..<1000 {
                monitor.updateSystemStats()
            }
        }
    }
    
    func testDiskIOPerformance() {
        let diskManager = DiskIOManager.shared
        let testData = Data(repeating: 0, count: 10 * 1024 * 1024) // 10MB
        
        measure(metrics: [XCTStorageMetric()]) {
            for i in 0..<10 {
                let path = NSTemporaryDirectory() + "test_\(i).dat"
                try? diskManager.writeFile(data: testData, to: path)
                _ = try? diskManager.readFile(at: path)
                try? FileManager.default.removeItem(atPath: path)
            }
        }
    }
    
    func testUIResponsiveness() {
        measure(metrics: [XCTClockMetric()]) {
            let app = XCUIApplication()
            app.launch()
            
            // UI 상호작용 테스트
            app.buttons["One-Click Optimize"].tap()
            app.buttons["지금 최적화"].tap()
            
            // 최적화 완료 대기
            let completionText = app.staticTexts["최적화 완료!"]
            XCTAssertTrue(completionText.waitForExistence(timeout: 10))
        }
    }
} 