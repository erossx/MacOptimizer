import SwiftUI

struct ContentView: View {
    @State private var selectedTab: SidebarItem = .dashboard
    
    var body: some View {
        NavigationSplitView {
            Sidebar(selection: $selectedTab)
        } detail: {
            DetailView(selectedTab: selectedTab)
        }
        .navigationSplitViewStyle(.balanced)
    }
}

// 사이드바 아이템 정의
enum SidebarItem: String, CaseIterable {
    case dashboard = "Dashboard"
    case oneClick = "One-Click Optimize"
    case disk = "Disk Cleanup"
    case memory = "Memory"
    case startup = "Startup Items"
    case settings = "Settings"
    
    var icon: String {
        switch self {
        case .dashboard: return "gauge"
        case .oneClick: return "bolt.circle"
        case .disk: return "internaldrive"
        case .memory: return "memorychip"
        case .startup: return "power"
        case .settings: return "gear"
        }
    }
} 