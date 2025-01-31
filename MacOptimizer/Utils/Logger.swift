import Foundation
import os.log

class Logger {
    static let shared = Logger()
    private let logger: OSLog
    
    private init() {
        self.logger = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.macoptimizer", category: "general")
    }
    
    func info(_ message: String) {
        os_log(.info, log: logger, "%{public}@", message)
        #if DEBUG
        print("ℹ️ [INFO] \(message)")
        #endif
    }
    
    func error(_ message: String) {
        os_log(.error, log: logger, "%{public}@", message)
        #if DEBUG
        print("❌ [ERROR] \(message)")
        #endif
    }
    
    func debug(_ message: String) {
        #if DEBUG
        os_log(.debug, log: logger, "%{public}@", message)
        print("🔍 [DEBUG] \(message)")
        #endif
    }
    
    func warning(_ message: String) {
        os_log(.default, log: logger, "%{public}@", message)
        #if DEBUG
        print("⚠️ [WARNING] \(message)")
        #endif
    }
} 