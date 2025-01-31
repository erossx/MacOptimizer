import XCTest
@testable import MacOptimizer

class DiskIOManagerTests: XCTestCase {
    var diskManager: DiskIOManager!
    let testFilePath = NSTemporaryDirectory() + "test.txt"
    let testData = "Hello, World!".data(using: .utf8)!
    
    override func setUp() {
        super.setUp()
        diskManager = DiskIOManager.shared
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(atPath: testFilePath)
        super.tearDown()
    }
    
    func testWriteAndReadFile() throws {
        // 파일 쓰기 테스트
        try diskManager.writeFile(data: testData, to: testFilePath)
        XCTAssertTrue(FileManager.default.fileExists(atPath: testFilePath))
        
        // 파일 읽기 테스트
        let readData = try diskManager.readFile(at: testFilePath)
        XCTAssertEqual(readData, testData)
    }
    
    func testFileOperationError() {
        // 잘못된 경로에 대한 에러 처리 테스트
        let invalidPath = "/invalid/path/test.txt"
        
        XCTAssertThrowsError(try diskManager.readFile(at: invalidPath)) { error in
            XCTAssertTrue(error is AppError)
            if case let AppError.fileSystemError(message) = error {
                XCTAssertTrue(message.contains("파일 읽기 실패"))
            }
        }
    }
} 