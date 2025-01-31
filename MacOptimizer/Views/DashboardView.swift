import SwiftUI

struct DashboardView: View {
    @StateObject private var systemMonitor = SystemMonitor()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("시스템 상태")
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    // CPU 사용량
                    SystemStatusCard(
                        title: "CPU 사용량",
                        value: String(format: "%.1f%%", systemMonitor.cpuUsage),
                        icon: "cpu"
                    )
                    
                    // 메모리 사용량
                    SystemStatusCard(
                        title: "메모리 사용량",
                        value: String(format: "%.1f GB", Double(systemMonitor.memoryUsage.used) / 1024 / 1024 / 1024),
                        icon: "memorychip"
                    )
                    
                    // 디스크 여유 공간
                    SystemStatusCard(
                        title: "디스크 여유 공간",
                        value: String(format: "%.1f GB", Double(systemMonitor.diskUsage.free) / 1024 / 1024 / 1024),
                        icon: "internaldrive"
                    )
                    
                    // 배터리 상태
                    SystemStatusCard(
                        title: "배터리 상태",
                        value: "\(systemMonitor.batteryInfo.percentage)%" + (systemMonitor.batteryInfo.isCharging ? " ⚡️" : ""),
                        icon: "battery.75"
                    )
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            // 알림 설정
            NotificationManager.shared.scheduleWeeklyReport()
            NotificationManager.shared.scheduleMonthlyReport()
            NotificationManager.shared.scheduleLowDiskSpaceAlert()
            NotificationManager.shared.scheduleHighMemoryUsageAlert()
        }
    }
} 