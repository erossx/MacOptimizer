import XCTest
@testable import MacOptimizer

class AppSettingsTests: XCTestCase {
    var settings: AppSettings!
    
    override func setUp() {
        super.setUp()
        // 테스트용 UserDefaults 초기화
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        settings = AppSettings.shared
    }
    
    func testDefaultValues() {
        XCTAssertFalse(settings.enableNotifications)
        XCTAssertFalse(settings.autoOptimize)
        XCTAssertEqual(settings.optimizeInterval, 24.0)
        XCTAssertFalse(settings.darkMode)
    }
    
    func testSettingsPersistence() {
        settings.enableNotifications = true
        settings.autoOptimize = true
        settings.optimizeInterval = 48.0
        settings.darkMode = true
        
        // 새로운 인스턴스 생성하여 값이 저장되었는지 확인
        let newSettings = AppSettings.shared
        XCTAssertTrue(newSettings.enableNotifications)
        XCTAssertTrue(newSettings.autoOptimize)
        XCTAssertEqual(newSettings.optimizeInterval, 48.0)
        XCTAssertTrue(newSettings.darkMode)
    }
} 