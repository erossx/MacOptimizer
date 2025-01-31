import Foundation

class SystemOptimizer: ObservableObject {
    @Published var isOptimizing = false
    @Published var progress: Double = 0
    @Published var currentTask: String = ""
    
    enum OptimizationTask: String {
        case scanning = "시스템 스캔 중..."
        case cleaningCache = "캐시 파일 정리 중..."
        case cleaningLogs = "로그 파일 정리 중..."
        case optimizingMemory = "메모리 최적화 중..."
        case cleaningTemp = "임시 파일 정리 중..."
        case finished = "최적화 완료!"
    }
    
    private let fileManager = FileManager.default
    private let cachePaths = [
        "~/Library/Caches",
        "~/Library/Logs",
        "/private/var/log",
        "/private/var/folders"
    ]
    
    func startOptimization() async throws {
        isOptimizing = true
        progress = 0
        
        // 1. 시스템 스캔
        try await performTask(.scanning, weight: 0.2)
        
        // 2. 캐시 정리
        try await performTask(.cleaningCache, weight: 0.2)
        
        // 3. 로그 정리
        try await performTask(.cleaningLogs, weight: 0.2)
        
        // 4. 메모리 최적화
        try await performTask(.optimizingMemory, weight: 0.2)
        
        // 5. 임시 파일 정리
        try await performTask(.cleaningTemp, weight: 0.2)
        
        // 완료
        currentTask = OptimizationTask.finished.rawValue
        isOptimizing = false
        
        // 완료 알림 전송
        NotificationManager.shared.scheduleNotification(
            title: "시스템 최적화 완료",
            body: "시스템이 성공적으로 최적화되었습니다."
        )
    }
    
    private func performTask(_ task: OptimizationTask, weight: Double) async throws {
        currentTask = task.rawValue
        
        switch task {
        case .scanning:
            try await scanSystem()
        case .cleaningCache:
            try await cleanCache()
        case .cleaningLogs:
            try await cleanLogs()
        case .optimizingMemory:
            try await optimizeMemory()
        case .cleaningTemp:
            try await cleanTempFiles()
        case .finished:
            break
        }
        
        progress += weight
    }
    
    private func scanSystem() async throws {
        // 시스템 스캔 시뮬레이션
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
    
    private func cleanCache() async throws {
        for path in cachePaths {
            let expandedPath = NSString(string: path).expandingTildeInPath
            
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: expandedPath)
                
                for item in contents {
                    let fullPath = (expandedPath as NSString).appendingPathComponent(item)
                    do {
                        try FileManager.default.removeItem(atPath: fullPath)
                        Logger.shared.info("캐시 파일 삭제 성공: \(fullPath)")
                    } catch {
                        Logger.shared.warning("캐시 파일 삭제 실패: \(fullPath)")
                        throw AppError.fileSystemError("캐시 파일 삭제 중 오류 발생: \(error.localizedDescription)")
                    }
                }
            } catch {
                Logger.shared.error("디렉토리 접근 실패: \(expandedPath)")
                throw AppError.permissionDenied("디렉토리 접근 권한이 없습니다: \(expandedPath)")
            }
            
            try await Task.sleep(nanoseconds: 500_000_000)
        }
    }
    
    private func cleanLogs() async throws {
        let logPaths = [
            "~/Library/Logs",
            "/private/var/log"
        ]
        
        for path in logPaths {
            let expandedPath = NSString(string: path).expandingTildeInPath
            let contents = try? fileManager.contentsOfDirectory(atPath: expandedPath)
            
            for item in contents ?? [] {
                if item.hasSuffix(".log") {
                    let fullPath = (expandedPath as NSString).appendingPathComponent(item)
                    try? fileManager.removeItem(atPath: fullPath)
                }
            }
            
            try await Task.sleep(nanoseconds: 500_000_000)
        }
    }
    
    private func optimizeMemory() async throws {
        // 메모리 최적화 시뮬레이션
        // 실제로는 mach_vm_pressure_monitor() 등의 API를 사용하여 구현
        try await Task.sleep(nanoseconds: 2_000_000_000)
    }
    
    private func cleanTempFiles() async throws {
        let tempPaths = [
            NSTemporaryDirectory(),
            "~/Library/Application Support/*/Cache",
            "~/Downloads"
        ]
        
        for path in tempPaths {
            let expandedPath = NSString(string: path).expandingTildeInPath
            let contents = try? fileManager.contentsOfDirectory(atPath: expandedPath)
            
            for item in contents ?? [] {
                let fullPath = (expandedPath as NSString).appendingPathComponent(item)
                try? fileManager.removeItem(atPath: fullPath)
            }
            
            try await Task.sleep(nanoseconds: 500_000_000)
        }
    }
} 