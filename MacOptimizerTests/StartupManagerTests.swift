import XCTest
@testable import MacOptimizer

class StartupManagerTests: XCTestCase {
    var startupManager: StartupManager!
    
    override func setUp() {
        super.setUp()
        startupManager = StartupManager()
    }
    
    func testLoadStartupItems() {
        startupManager.loadStartupItems()
        
        // 시작 프로그램 목록이 비어있지 않은지 확인
        XCTAssertFalse(startupManager.startupItems.isEmpty)
        
        // 각 항목이 필수 정보를 가지고 있는지 확인
        for item in startupManager.startupItems {
            XCTAssertFalse(item.id.isEmpty)
            XCTAssertFalse(item.name.isEmpty)
        }
    }
    
    func testToggleStartupItem() {
        startupManager.loadStartupItems()
        
        guard let firstItem = startupManager.startupItems.first else {
            XCTFail("No startup items found")
            return
        }
        
        let initialState = firstItem.isEnabled
        startupManager.toggleStartupItem(firstItem)
        
        // 토글 후 상태가 변경되었는지 확인
        if let updatedItem = startupManager.startupItems.first {
            XCTAssertNotEqual(initialState, updatedItem.isEnabled)
        }
    }
} 