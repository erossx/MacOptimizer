import Foundation
import AppKit
import Darwin

class MemoryManager {
    static let shared = MemoryManager()
    
    private init() {}
    
    func optimizeMemory() async throws {
        // 1. 메모리 압축 실행
        await compressMemory()
        
        // 2. 불필요한 캐시 정리
        clearCaches()
        
        // 3. 메모리 해제 요청
        requestMemoryRelease()
    }
    
    private func compressMemory() async {
        // 메모리 압축 명령어 실행
        let task = Process()
        task.launchPath = "/usr/bin/purge"
        
        do {
            try task.run()
            task.waitUntilExit()
            Logger.shared.info("메모리 압축 완료")
        } catch {
            Logger.shared.error("메모리 압축 실패: \(error.localizedDescription)")
        }
    }
    
    private func clearCaches() {
        autoreleasepool {
            // URL 캐시 정리
            URLCache.shared.removeAllCachedResponses()
            
            // 이미지 캐시 정리
            NSWorkspace.shared.notificationCenter.post(name: NSWorkspace.didTerminateApplicationNotification, object: nil)
            
            // 파일 핸들러 캐시 정리
            try? FileManager.default.clearTemporaryFiles()
        }
    }
    
    private func requestMemoryRelease() {
        malloc_zone_pressure_relief(nil, 0)
    }
    
    func getMemoryUsage() -> (used: UInt64, total: UInt64, free: UInt64) {
        var pageSize: vm_size_t = 0
        let hostPort = mach_host_self()
        host_page_size(hostPort, &pageSize)
        
        var vmStats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
        
        let result = withUnsafeMutablePointer(to: &vmStats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(hostPort, HOST_VM_INFO64, $0, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            let free = UInt64(vmStats.free_count) * UInt64(pageSize)
            let active = UInt64(vmStats.active_count) * UInt64(pageSize)
            let inactive = UInt64(vmStats.inactive_count) * UInt64(pageSize)
            let wired = UInt64(vmStats.wire_count) * UInt64(pageSize)
            
            let used = active + inactive + wired
            let total = used + free
            
            return (used: used, total: total, free: free)
        }
        
        return (used: 0, total: 0, free: 0)
    }
    
    func getRunningProcesses() -> [(name: String, memoryUsage: UInt64)] {
        var processes: [(name: String, memoryUsage: UInt64)] = []
        
        let ws = NSWorkspace.shared
        let runningApps = ws.runningApplications
        
        for app in runningApps {
            if let name = app.localizedName {
                var taskInfo = mach_task_basic_info()
                var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size / 4)
                
                let result = withUnsafeMutablePointer(to: &taskInfo) {
                    $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                        task_info(task_name_t(app.processIdentifier), task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
                    }
                }
                
                if result == KERN_SUCCESS {
                    let memoryUsage = UInt64(taskInfo.resident_size)
                    processes.append((name: name, memoryUsage: memoryUsage))
                }
            }
        }
        
        return processes.sorted { $0.memoryUsage > $1.memoryUsage }
    }
}

extension FileManager {
    func clearTemporaryFiles() throws {
        let tempDir = NSTemporaryDirectory()
        let contents = try contentsOfDirectory(atPath: tempDir)
        
        for file in contents {
            let filePath = (tempDir as NSString).appendingPathComponent(file)
            do {
                try removeItem(atPath: filePath)
            } catch {
                Logger.shared.error("임시 파일 삭제 실패: \(filePath) - \(error.localizedDescription)")
            }
        }
    }
} 
