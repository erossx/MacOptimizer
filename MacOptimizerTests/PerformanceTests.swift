import XCTest
@testable import MacOptimizer

class PerformanceTests: XCTestCase {
    func testSystemMonitorPerformance() {
        let monitor = SystemMonitor()
        
        measure {
            monitor.updateSystemStats()
        }
    }
    
    func testFileOperationsPerformance() {
        let diskManager = DiskIOManager.shared
        let testData = Data(repeating: 0, count: 1024 * 1024) // 1MB
        
        measure {
            try? diskManager.writeFile(data: testData, to: NSTemporaryDirectory() + "/test.dat")
            _ = try? diskManager.readFile(at: NSTemporaryDirectory() + "/test.dat")
        }
    }
    
    func testMemoryCleanupPerformance() {
        let memoryManager = MemoryManager.shared
        
        measure {
            memoryManager.cleanup()
        }
    }
} 