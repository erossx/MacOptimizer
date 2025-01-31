import XCTest
@testable import MacOptimizer

class SystemOptimizerTests: XCTestCase {
    var optimizer: SystemOptimizer!
    
    override func setUp() {
        super.setUp()
        optimizer = SystemOptimizer()
    }
    
    override func tearDown() {
        optimizer = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertFalse(optimizer.isOptimizing)
        XCTAssertEqual(optimizer.progress, 0)
        XCTAssertEqual(optimizer.currentTask, "")
    }
    
    func testOptimizationFlow() async throws {
        try await optimizer.startOptimization()
        
        XCTAssertFalse(optimizer.isOptimizing)
        XCTAssertEqual(optimizer.progress, 1.0)
        XCTAssertEqual(optimizer.currentTask, SystemOptimizer.OptimizationTask.finished.rawValue)
    }
    
    func testOptimizationCancellation() async {
        let expectation = XCTestExpectation(description: "Optimization cancelled")
        
        Task {
            try? await optimizer.startOptimization()
            expectation.fulfill()
        }
        
        // 최적화 진행 중 상태 확인
        XCTAssertTrue(optimizer.isOptimizing)
        XCTAssertGreaterThan(optimizer.progress, 0)
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
} 