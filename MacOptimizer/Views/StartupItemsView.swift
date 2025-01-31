import SwiftUI

struct StartupItemsView: View {
    @StateObject private var startupManager = StartupManager()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("시작 프로그램")
                .font(.largeTitle)
                .bold()
            
            Text("로그인 시 자동으로 실행될 앱을 선택하세요")
                .foregroundColor(.secondary)
            
            List {
                Section("로그인 아이템") {
                    ForEach(startupManager.startupItems.filter { $0.type == .loginItem }) { item in
                        StartupItemRow(item: item) {
                            startupManager.toggleStartupItem(item)
                        }
                    }
                }
                
                Section("Launch Agents") {
                    ForEach(startupManager.startupItems.filter { $0.type == .launchAgent }) { item in
                        StartupItemRow(item: item) {
                            startupManager.toggleStartupItem(item)
                        }
                    }
                }
                
                Section("시스템 Launch Agents") {
                    ForEach(startupManager.startupItems.filter { $0.type == .systemLaunchAgent }) { item in
                        StartupItemRow(item: item) {
                            startupManager.toggleStartupItem(item)
                        }
                    }
                }
            }
            .listStyle(.inset)
        }
        .padding()
        .onAppear {
            startupManager.loadStartupItems()
        }
    }
}

struct StartupItemRow: View {
    let item: StartupItem
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.accentColor)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                Text(item.type.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: .init(
                get: { item.isEnabled },
                set: { _ in onToggle() }
            ))
        }
        .padding(.vertical, 4)
    }
    
    private var iconName: String {
        switch item.type {
        case .loginItem:
            return "app.badge.checkmark"
        case .launchAgent:
            return "gear"
        case .systemLaunchAgent:
            return "gearshape.2"
        }
    }
}

extension StartupItemType {
    var description: String {
        switch self {
        case .loginItem:
            return "로그인 아이템"
        case .launchAgent:
            return "사용자 Launch Agent"
        case .systemLaunchAgent:
            return "시스템 Launch Agent"
        }
    }
} 