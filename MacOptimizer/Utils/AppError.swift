import Foundation

enum AppError: LocalizedError {
    case fileSystemError(String)
    case permissionDenied(String)
    case optimizationError(String)
    case systemError(String)
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .fileSystemError(let message):
            return "파일 시스템 오류: \(message)"
        case .permissionDenied(let message):
            return "권한 오류: \(message)"
        case .optimizationError(let message):
            return "최적화 오류: \(message)"
        case .systemError(let message):
            return "시스템 오류: \(message)"
        case .networkError(let message):
            return "네트워크 오류: \(message)"
        }
    }
}

class ErrorHandler {
    static let shared = ErrorHandler()
    
    func handle(_ error: Error) {
        // 에러 로깅
        Logger.shared.log(error.localizedDescription, level: .error)
        
        // 사용자에게 알림
        if let appError = error as? AppError {
            NotificationManager.shared.scheduleNotification(
                title: "오류 발생",
                body: appError.localizedDescription
            )
        }
        
        // 크래시 리포팅 서비스로 전송 (예: Crashlytics)
        // sendToCrashlytics(error)
    }
} 