import Foundation
import CryptoKit

class DiskIOManager {
    static let shared = DiskIOManager()
    
    private init() {}
    
    func getDiskSpace() -> (total: UInt64, used: UInt64, free: UInt64) {
        let fileURL = URL(fileURLWithPath: "/")
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityKey])
            if let total = values.volumeTotalCapacity,
               let free = values.volumeAvailableCapacity {
                let used = UInt64(total - free)
                return (total: UInt64(total), used: used, free: UInt64(free))
            }
        } catch {
            Logger.shared.error("디스크 공간 정보 조회 실패: \(error.localizedDescription)")
        }
        return (0, 0, 0)
    }
    
    func scanLargeFiles(in directory: String, threshold: UInt64 = 100 * 1024 * 1024) -> [URL] {
        var largeFiles: [URL] = []
        let fileManager = FileManager.default
        
        guard let enumerator = fileManager.enumerator(atPath: directory) else {
            Logger.shared.error("디렉토리 접근 실패: \(directory)")
            return []
        }
        
        while let filePath = enumerator.nextObject() as? String {
            let fullPath = (directory as NSString).appendingPathComponent(filePath)
            do {
                let attributes = try fileManager.attributesOfItem(atPath: fullPath)
                if let fileSize = attributes[.size] as? UInt64,
                   fileSize >= threshold {
                    largeFiles.append(URL(fileURLWithPath: fullPath))
                }
            } catch {
                Logger.shared.error("파일 속성 조회 실패: \(fullPath) - \(error.localizedDescription)")
            }
        }
        
        return largeFiles.sorted { (url1, url2) -> Bool in
            do {
                let attr1 = try FileManager.default.attributesOfItem(atPath: url1.path)
                let attr2 = try FileManager.default.attributesOfItem(atPath: url2.path)
                let size1 = attr1[.size] as? UInt64 ?? 0
                let size2 = attr2[.size] as? UInt64 ?? 0
                return size1 > size2
            } catch {
                Logger.shared.error("파일 크기 비교 실패: \(error.localizedDescription)")
                return false
            }
        }
    }
    
    func cleanDirectory(_ path: String, olderThan days: Int = 7) -> Bool {
        let fileManager = FileManager.default
        let cutoffDate = Date().addingTimeInterval(-TimeInterval(days * 24 * 60 * 60))
        
        guard let enumerator = fileManager.enumerator(atPath: path) else {
            Logger.shared.error("디렉토리 접근 실패: \(path)")
            return false
        }
        
        var success = true
        while let filePath = enumerator.nextObject() as? String {
            let fullPath = (path as NSString).appendingPathComponent(filePath)
            do {
                let attributes = try fileManager.attributesOfItem(atPath: fullPath)
                if let modificationDate = attributes[.modificationDate] as? Date,
                   modificationDate < cutoffDate {
                    try fileManager.removeItem(atPath: fullPath)
                    Logger.shared.info("파일 삭제 완료: \(fullPath)")
                }
            } catch {
                Logger.shared.error("파일 삭제 실패: \(fullPath) - \(error.localizedDescription)")
                success = false
            }
        }
        
        return success
    }
    
    func getDuplicateFiles(in directory: String) -> [String: [URL]] {
        var fileHashes: [String: [URL]] = [:]
        let fileManager = FileManager.default
        
        guard let enumerator = fileManager.enumerator(atPath: directory) else {
            Logger.shared.error("디렉토리 접근 실패: \(directory)")
            return [:]
        }
        
        while let filePath = enumerator.nextObject() as? String {
            let fullPath = (directory as NSString).appendingPathComponent(filePath)
            guard let data = fileManager.contents(atPath: fullPath) else { continue }
            
            let hash = SHA256.hash(data: data).compactMap { String(format: "%02x", $0) }.joined()
            let url = URL(fileURLWithPath: fullPath)
            
            if fileHashes[hash] != nil {
                fileHashes[hash]?.append(url)
            } else {
                fileHashes[hash] = [url]
            }
        }
        
        // 중복된 파일만 반환
        return fileHashes.filter { $0.value.count > 1 }
    }
}

// SHA-256 해시 계산을 위한 헬퍼 구조체
private struct SHA256 {
    static func hash(data: Data) -> Data {
        let digest = CryptoKit.SHA256.hash(data: data)
        return Data(digest)
    }
} 