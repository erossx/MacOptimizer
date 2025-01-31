import SwiftUI

struct SettingsView: View {
    @StateObject private var settings = AppSettings.shared
    
    var body: some View {
        Form {
            Section("알림") {
                Toggle("시스템 상태 알림", isOn: $settings.enableNotifications)
                    .toggleStyle(.switch)
            }
            
            Section("자동 최적화") {
                Toggle("자동 최적화 사용", isOn: $settings.autoOptimize)
                    .toggleStyle(.switch)
                
                if settings.autoOptimize {
                    VStack(alignment: .leading) {
                        Text("최적화 주기: \(Int(settings.optimizeInterval))시간")
                        Slider(value: $settings.optimizeInterval, in: 1...72, step: 1)
                    }
                }
            }
            
            Section("앱 설정") {
                Toggle("다크 모드", isOn: $settings.darkMode)
                    .toggleStyle(.switch)
            }
            
            Section("정보") {
                LabeledContent("버전", value: Bundle.main.appVersion)
                LabeledContent("빌드", value: Bundle.main.buildNumber)
                
                Button("업데이트 확인") {
                    checkForUpdates()
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
    
    private func checkForUpdates() {
        // 업데이트 확인 로직 구현
        // 예: GitHub API를 통한 최신 릴리즈 확인
    }
}

extension Bundle {
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
} 