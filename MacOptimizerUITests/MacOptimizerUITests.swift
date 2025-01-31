import XCTest

class MacOptimizerUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testDashboardView() {
        // CPU 사용량 카드 확인
        XCTAssertTrue(app.staticTexts["CPU 사용량"].exists)
        
        // 메모리 사용량 카드 확인
        XCTAssertTrue(app.staticTexts["메모리 사용량"].exists)
        
        // 디스크 여유 공간 카드 확인
        XCTAssertTrue(app.staticTexts["디스크 여유 공간"].exists)
    }
    
    func testOneClickOptimize() {
        // 원클릭 최적화 탭으로 이동
        app.buttons["One-Click Optimize"].click()
        
        // 최적화 버튼 확인
        let optimizeButton = app.buttons["지금 최적화"]
        XCTAssertTrue(optimizeButton.exists)
        
        // 최적화 실행
        optimizeButton.click()
        
        // 진행 상태 확인
        XCTAssertTrue(app.progressIndicators.firstMatch.exists)
        
        // 완료 대기
        let completionText = app.staticTexts["최적화 완료!"]
        XCTAssertTrue(completionText.waitForExistence(timeout: 10))
    }
    
    func testSettingsView() {
        // 설정 탭으로 이동
        app.buttons["Settings"].click()
        
        // 알림 설정 토글 확인
        let notificationToggle = app.switches["시스템 상태 알림"]
        XCTAssertTrue(notificationToggle.exists)
        
        // 다크 모드 토글 확인
        let darkModeToggle = app.switches["다크 모드"]
        XCTAssertTrue(darkModeToggle.exists)
    }
} 