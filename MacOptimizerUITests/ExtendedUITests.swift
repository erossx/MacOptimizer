import XCTest

class ExtendedUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testNavigationFlow() {
        // 모든 탭 순차적으로 이동하며 테스트
        let tabs = ["Dashboard", "One-Click Optimize", "Disk Cleanup", "Memory", "Startup Items", "Settings"]
        
        for tab in tabs {
            app.buttons[tab].click()
            XCTAssertTrue(app.buttons[tab].isSelected)
            // 각 화면의 주요 요소 확인
            let mainTitle = app.staticTexts[tab].firstMatch
            XCTAssertTrue(mainTitle.exists)
        }
    }
    
    func testDiskCleanupFlow() {
        // 디스크 정리 화면으로 이동
        app.buttons["Disk Cleanup"].click()
        
        // 스캔 버튼 클릭
        let scanButton = app.buttons["스캔"]
        XCTAssertTrue(scanButton.exists)
        scanButton.click()
        
        // 스캔 진행 상태 확인
        XCTAssertTrue(app.progressIndicators.firstMatch.exists)
        
        // 정리 항목 선택
        let cleanupItems = app.tables.cells
        if cleanupItems.count > 0 {
            cleanupItems.firstMatch.tap()
        }
        
        // 정리 버튼 활성화 확인
        let cleanupButton = app.buttons["선택 항목 정리"]
        XCTAssertTrue(cleanupButton.isEnabled)
    }
    
    func testMemoryOptimizationFlow() {
        // 메모리 화면으로 이동
        app.buttons["Memory"].click()
        
        // 메모리 상태 표시 확인
        XCTAssertTrue(app.progressIndicators["메모리 사용량"].exists)
        
        // 최적화 버튼 클릭
        let optimizeButton = app.buttons["메모리 최적화"]
        XCTAssertTrue(optimizeButton.exists)
        optimizeButton.click()
        
        // 최적화 진행 상태 확인
        XCTAssertTrue(app.progressIndicators["최적화 진행률"].exists)
    }
    
    func testSettingsInteraction() {
        // 설정 화면으로 이동
        app.buttons["Settings"].click()
        
        // 알림 설정 토글
        let notificationToggle = app.switches["시스템 상태 알림"]
        XCTAssertTrue(notificationToggle.exists)
        notificationToggle.tap()
        
        // 자동 최적화 설정
        let autoOptimizeToggle = app.switches["자동 최적화 사용"]
        XCTAssertTrue(autoOptimizeToggle.exists)
        autoOptimizeToggle.tap()
        
        // 최적화 주기 슬라이더 확인
        XCTAssertTrue(app.sliders["최적화 주기"].exists)
        
        // 다크 모드 토글
        let darkModeToggle = app.switches["다크 모드"]
        XCTAssertTrue(darkModeToggle.exists)
        darkModeToggle.tap()
    }
    
    func testAccessibility() {
        // 접근성 레이블 확인
        XCTAssertTrue(app.buttons["지금 최적화"].isAccessibilityElement)
        XCTAssertTrue(app.staticTexts["CPU 사용량"].isAccessibilityElement)
        
        // VoiceOver 네비게이션 테스트
        let elements = app.descendants(matching: .any).allElementsBoundByAccessibilityElement
        for element in elements {
            XCTAssertNotNil(element.identifier)
        }
    }
} 