import SwiftUI

struct SystemStatusView: View {
    @StateObject private var systemMonitor = SystemMonitor()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("시스템 상태 모니터링")
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                // CPU 사용량 그래프
                VStack(alignment: .leading, spacing: 8) {
                    Text("CPU 사용량")
                        .font(.headline)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color(.systemGray5))
                                .frame(width: geometry.size.width, height: 20)
                                .cornerRadius(10)
                            
                            Rectangle()
                                .fill(Color.accentColor)
                                .frame(width: geometry.size.width * CGFloat(systemMonitor.cpuUsage / 100.0), height: 20)
                                .cornerRadius(10)
                        }
                    }
                    .frame(height: 20)
                    
                    Text("\(String(format: "%.1f%%", systemMonitor.cpuUsage))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.windowBackgroundColor))
                .cornerRadius(10)
                
                // 메모리 사용량
                VStack(alignment: .leading, spacing: 8) {
                    Text("메모리 사용량")
                        .font(.headline)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color(.systemGray5))
                                .frame(width: geometry.size.width, height: 20)
                                .cornerRadius(10)
                            
                            Rectangle()
                                .fill(Color.accentColor)
                                .frame(width: geometry.size.width * CGFloat(Double(systemMonitor.memoryUsage.used) / Double(systemMonitor.memoryUsage.total)), height: 20)
                                .cornerRadius(10)
                        }
                    }
                    .frame(height: 20)
                    
                    HStack {
                        Text("사용 중: \(String(format: "%.1f GB", Double(systemMonitor.memoryUsage.used) / 1024 / 1024 / 1024))")
                        Spacer()
                        Text("전체: \(String(format: "%.1f GB", Double(systemMonitor.memoryUsage.total) / 1024 / 1024 / 1024))")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.windowBackgroundColor))
                .cornerRadius(10)
                
                // 디스크 사용량
                VStack(alignment: .leading, spacing: 8) {
                    Text("디스크 사용량")
                        .font(.headline)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color(.systemGray5))
                                .frame(width: geometry.size.width, height: 20)
                                .cornerRadius(10)
                            
                            Rectangle()
                                .fill(Color.accentColor)
                                .frame(width: geometry.size.width * CGFloat(Double(systemMonitor.diskUsage.used) / Double(systemMonitor.diskUsage.total)), height: 20)
                                .cornerRadius(10)
                        }
                    }
                    .frame(height: 20)
                    
                    HStack {
                        Text("사용 중: \(String(format: "%.1f GB", Double(systemMonitor.diskUsage.used) / 1024 / 1024 / 1024))")
                        Spacer()
                        Text("여유: \(String(format: "%.1f GB", Double(systemMonitor.diskUsage.free) / 1024 / 1024 / 1024))")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.windowBackgroundColor))
                .cornerRadius(10)
                
                // 배터리 상태
                if systemMonitor.batteryInfo.percentage > 0 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("배터리 상태")
                            .font(.headline)
                        
                        HStack {
                            Image(systemName: systemMonitor.batteryInfo.isCharging ? "battery.100.bolt" : "battery.\(systemMonitor.batteryInfo.percentage)")
                                .font(.title)
                                .foregroundColor(getBatteryColor(percentage: systemMonitor.batteryInfo.percentage))
                            
                            VStack(alignment: .leading) {
                                Text("\(systemMonitor.batteryInfo.percentage)%")
                                    .font(.title2)
                                Text("충전 사이클: \(systemMonitor.batteryInfo.cycleCount)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            if systemMonitor.batteryInfo.isCharging {
                                Image(systemName: "bolt.fill")
                                    .font(.title2)
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.windowBackgroundColor))
                    .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    private func getBatteryColor(percentage: Int) -> Color {
        switch percentage {
        case 0...20:
            return .red
        case 21...50:
            return .orange
        default:
            return .green
        }
    }
} 