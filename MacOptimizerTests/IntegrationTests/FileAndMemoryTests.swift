import XCTest
@testable import MacOptimizer

class FileAndMemoryTests: XCTestCase {
    var diskManager: DiskIOManager!
    var memoryManager: MemoryManager!
    var systemMonitor: SystemMonitor!
    
    override func setUp() {
        super.setUp()
        diskManager = DiskIOManager.shared
        memoryManager = MemoryManager.shared
        systemMonitor = SystemMonitor()
    }
    
    func testFileOperationsWithMemoryManagement() async throws {
        // 1. 초기 메모리 상태 기록
        let initialMemoryUsage = systemMonitor.memoryUsage.used
        
        // 2. 대용량 파일 작업 수행
        let testData = Data(repeating: 0, count: 100 * 1024 * 1024) // 100MB
        let testPath = NSTemporaryDirectory() + "large_test_file.dat"
        
        try diskManager.writeFile(data: testData, to: testPath)
        
        // 3. 메모리 정리 수행
        memoryManager.cleanup()
        
        // 4. 메모리 사용량 확인
        XCTAssertLessThanOrEqual(systemMonitor.memoryUsage.used, initialMemoryUsage * 1.1) // 10% 이내 증가 허용
        
        // 5. 파일 삭제
        try? FileManager.default.removeItem(atPath: testPath)
    }
    
    func testConcurrentFileOperations() async throws {
        let operationCount = 10
        let expectations = (0..<operationCount).map { i in
            XCTestExpectation(description: "File operation \(i)")
        }
        
        // 여러 파일 작업을 동시에 수행
        for i in 0..<operationCount {
            let testData = "Test data \(i)".data(using: .utf8)!
            let testPath = NSTemporaryDirectory() + "test_file_\(i).txt"
            
            diskManager.performDiskOperation {
                try diskManager.writeFile(data: testData, to: testPath)
                try? FileManager.default.removeItem(atPath: testPath)
                expectations[i].fulfill()
            }
        }
        
        await fulfillment(of: expectations, timeout: 10.0)
    }
} 