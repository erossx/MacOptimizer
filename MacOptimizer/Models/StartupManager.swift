import Foundation
import AppKit

class StartupManager: ObservableObject {
    @Published var startupItems: [StartupItem] = []
    
    private let loginItemsPath = "~/Library/Application Support/com.apple.loginitems.plist"
    private let launchAgentsPath = "~/Library/LaunchAgents"
    private let systemLaunchAgentsPath = "/Library/LaunchAgents"
    
    func loadStartupItems() {
        startupItems.removeAll()
        
        // 로그인 아이템 로드
        loadLoginItems()
        
        // Launch Agents 로드
        loadLaunchAgents()
        
        // System Launch Agents 로드
        loadSystemLaunchAgents()
    }
    
    private func loadLoginItems() {
        let workspace = NSWorkspace.shared
        let loginItems = workspace.runningApplications.filter { app in
            app.launchDate != nil
        }
        
        for app in loginItems {
            if let bundleIdentifier = app.bundleIdentifier {
                startupItems.append(StartupItem(
                    id: bundleIdentifier,
                    name: app.localizedName ?? "Unknown",
                    type: .loginItem,
                    isEnabled: true,
                    bundleIdentifier: bundleIdentifier
                ))
            }
        }
    }
    
    private func loadLaunchAgents() {
        let expandedPath = (launchAgentsPath as NSString).expandingTildeInPath
        let fileManager = FileManager.default
        
        guard let contents = try? fileManager.contentsOfDirectory(atPath: expandedPath) else { return }
        
        for item in contents where item.hasSuffix(".plist") {
            if let plist = NSDictionary(contentsOfFile: (expandedPath as NSString).appendingPathComponent(item)) {
                let label = plist["Label"] as? String ?? item
                let isEnabled = !(plist["Disabled"] as? Bool ?? false)
                
                startupItems.append(StartupItem(
                    id: label,
                    name: label.components(separatedBy: ".").last ?? label,
                    type: .launchAgent,
                    isEnabled: isEnabled,
                    path: (expandedPath as NSString).appendingPathComponent(item)
                ))
            }
        }
    }
    
    private func loadSystemLaunchAgents() {
        let fileManager = FileManager.default
        guard let contents = try? fileManager.contentsOfDirectory(atPath: systemLaunchAgentsPath) else { return }
        
        for item in contents where item.hasSuffix(".plist") {
            if let plist = NSDictionary(contentsOfFile: (systemLaunchAgentsPath as NSString).appendingPathComponent(item)) {
                let label = plist["Label"] as? String ?? item
                let isEnabled = !(plist["Disabled"] as? Bool ?? false)
                
                startupItems.append(StartupItem(
                    id: label,
                    name: label.components(separatedBy: ".").last ?? label,
                    type: .systemLaunchAgent,
                    isEnabled: isEnabled,
                    path: (systemLaunchAgentsPath as NSString).appendingPathComponent(item)
                ))
            }
        }
    }
    
    func toggleStartupItem(_ item: StartupItem) {
        switch item.type {
        case .loginItem:
            toggleLoginItem(item)
        case .launchAgent, .systemLaunchAgent:
            toggleLaunchAgent(item)
        }
    }
    
    private func toggleLoginItem(_ item: StartupItem) {
        guard let bundleIdentifier = item.bundleIdentifier else { return }
        
        if item.isEnabled {
            // 로그인 아이템 비활성화
            if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
                let config = NSWorkspace.OpenConfiguration()
                config.arguments = ["--background"]
                NSWorkspace.shared.openApplication(at: url, configuration: config) { app, error in
                    if error == nil {
                        app?.terminate()
                    }
                }
            }
        } else {
            // 로그인 아이템 활성화
            if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
                let config = NSWorkspace.OpenConfiguration()
                config.arguments = ["--background"]
                NSWorkspace.shared.openApplication(at: url, configuration: config)
            }
        }
        
        if let index = startupItems.firstIndex(where: { $0.id == item.id }) {
            startupItems[index].isEnabled.toggle()
        }
    }
    
    private func toggleLaunchAgent(_ item: StartupItem) {
        guard let path = item.path else { return }
        
        if let plist = NSMutableDictionary(contentsOfFile: path) {
            plist["Disabled"] = !item.isEnabled
            plist.write(toFile: path, atomically: true)
            
            if let index = startupItems.firstIndex(where: { $0.id == item.id }) {
                startupItems[index].isEnabled.toggle()
            }
        }
    }
}

struct StartupItem: Identifiable {
    let id: String
    let name: String
    let type: StartupItemType
    var isEnabled: Bool
    var bundleIdentifier: String?
    var path: String?
}

enum StartupItemType {
    case loginItem
    case launchAgent
    case systemLaunchAgent
} 
