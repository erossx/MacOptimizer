import XCTest
@testable import MacOptimizer

class SystemMonitorTests: XCTestCase {
    var systemMonitor: SystemMonitor!
    
    override func setUp() {
        super.setUp()
        systemMonitor = SystemMonitor()
    }
    
    override func tearDown() {
        systemMonitor.stopMonitoring()
        systemMonitor = nil
        super.tearDown()
    }
    
    func testInitialValues() {
        XCTAssertEqual(systemMonitor.cpuUsage, 0.0)
        XCTAssertEqual(systemMonitor.memoryUsage.total, 0)
        XCTAssertEqual(systemMonitor.memoryUsage.used, 0)
        XCTAssertEqual(systemMonitor.memoryUsage.free, 0)
    }
    
    func testMemoryUsagePercentage() {
        let memoryUsage = MemoryUsage(total: 1000, used: 600, free: 400)
        XCTAssertEqual(memoryUsage.usagePercentage, 60.0)
    }
    
    func testMonitoringStartStop() {
        systemMonitor.startMonitoring()
        XCTAssertNotNil(systemMonitor.timer)
        
        systemMonitor.stopMonitoring()
        XCTAssertNil(systemMonitor.timer)
    }
} 