import Foundation

enum SidebarItem: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case systemStatus = "System Status"
    case oneClickOptimize = "Quick Optimize"
    case diskCleaner = "Disk Cleaner"
    case memoryManager = "Memory Manager"
    case startupItems = "Startup Items"
    case settings = "Settings"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .dashboard:
            return "gauge"
        case .systemStatus:
            return "cpu"
        case .oneClickOptimize:
            return "sparkles"
        case .diskCleaner:
            return "internaldrive"
        case .memoryManager:
            return "memorychip"
        case .startupItems:
            return "power"
        case .settings:
            return "gearshape"
        }
    }
} 