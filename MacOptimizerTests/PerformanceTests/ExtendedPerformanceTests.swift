import XCTest
@testable import MacOptimizer

class ExtendedPerformanceTests: XCTestCase {
    func testSystemMonitoringPerformance() {
        let monitor = SystemMonitor()
        
        measure(metrics: [XCTCPUMetric(), XCTMemoryMetric(), XCTStorageMetric()]) {
            for _ in 0..<100 {
                monitor.updateSystemStats()
                RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.01))
            }
        }
    }
    
    func testOptimizationPerformance() async throws {
        let optimizer = SystemOptimizer()
        
        measure(metrics: [XCTCPUMetric(), XCTMemoryMetric()]) {
            Task {
                try? await optimizer.startOptimization()
            }
        }
    }
    
    func testConcurrentOperationsPerformance() {
        let diskManager = DiskIOManager.shared
        let memoryManager = MemoryManager.shared
        
        measure(metrics: [XCTCPUMetric(), XCTMemoryMetric(), XCTStorageMetric()]) {
            let group = DispatchGroup()
            
            // 디스크 작업
            group.enter()
            diskManager.performDiskOperation {
                // 테스트 파일 작업
                group.leave()
            }
            
            // 메모리 정리
            group.enter()
            DispatchQueue.global().async {
                memoryManager.cleanup()
                group.leave()
            }
            
            group.wait()
        }
    }
} 