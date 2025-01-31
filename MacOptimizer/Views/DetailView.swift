import SwiftUI

struct DetailView: View {
    let selectedTab: SidebarItem
    
    var body: some View {
        switch selectedTab {
        case .dashboard:
            DashboardView()
        case .systemStatus:
            SystemStatusView()
        case .oneClickOptimize:
            OneClickOptimizeView()
        case .diskCleaner:
            DiskCleanerView()
        case .memoryManager:
            MemoryManagerView()
        case .startupItems:
            StartupItemsView()
        case .settings:
            SettingsView()
        }
    }
} 