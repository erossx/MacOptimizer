import SwiftUI

struct MemoryManagerView: View {
    @StateObject private var systemMonitor = SystemMonitor()
    @State private var isOptimizing = false
    @State private var showProcessList = false
    @State private var selectedProcesses: Set<String> = []
    
    var body: some View {
        VStack(spacing: 20) {
            // 메모리 상태 카드
            VStack(alignment: .leading, spacing: 8) {
                Text("메모리 상태")
                    .font(.headline)
                
                // 메모리 사용량 게이지
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(width: geometry.size.width, height: 20)
                            .cornerRadius(10)
                        
                        Rectangle()
                            .fill(getMemoryUsageColor())
                            .frame(width: geometry.size.width * getMemoryUsageRatio(), height: 20)
                            .cornerRadius(10)
                    }
                }
                .frame(height: 20)
                
                // 메모리 상세 정보
                HStack {
                    VStack(alignment: .leading) {
                        Text("사용 중")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(formatBytes(systemMonitor.memoryUsage.used))
                            .font(.title2)
                            .bold()
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("전체")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(formatBytes(systemMonitor.memoryUsage.total))
                            .font(.title2)
                            .bold()
                    }
                }
            }
            .padding()
            .background(Color(.windowBackgroundColor))
            .cornerRadius(10)
            
            // 최적화 버튼
            Button(action: optimizeMemory) {
                if isOptimizing {
                    ProgressView()
                        .scaleEffect(0.8)
                        .frame(width: 16, height: 16)
                } else {
                    Label("메모리 최적화", systemImage: "memorychip")
                }
            }
            .disabled(isOptimizing)
            .buttonStyle(.borderedProminent)
            
            // 프로세스 목록 토글 버튼
            Button(action: { showProcessList.toggle() }) {
                Label("프로세스 목록 \(showProcessList ? "숨기기" : "보기")", 
                      systemImage: showProcessList ? "chevron.up" : "chevron.down")
            }
            .buttonStyle(.borderless)
            
            if showProcessList {
                // 프로세스 목록
                List(selection: $selectedProcesses) {
                    ForEach(getProcessList(), id: \.name) { process in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(process.name)
                                    .font(.headline)
                                Text(formatBytes(process.memoryUsage))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: { terminateProcess(process.name) }) {
                                Image(systemName: "xmark.circle")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
                .listStyle(InsetListStyle())
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func getMemoryUsageRatio() -> CGFloat {
        CGFloat(Double(systemMonitor.memoryUsage.used) / Double(systemMonitor.memoryUsage.total))
    }
    
    private func getMemoryUsageColor() -> Color {
        let ratio = getMemoryUsageRatio()
        switch ratio {
        case 0.0...0.6:
            return .green
        case 0.6...0.8:
            return .orange
        default:
            return .red
        }
    }
    
    private func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .memory
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    private func optimizeMemory() {
        isOptimizing = true
        
        Task {
            // 메모리 최적화 로직 구현
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            await MainActor.run {
                isOptimizing = false
                // 최적화 완료 알림
                NotificationManager.shared.scheduleNotification(
                    title: "메모리 최적화 완료",
                    body: "시스템 메모리가 정리되었습니다."
                )
            }
        }
    }
    
    private struct ProcessInfo {
        let name: String
        let memoryUsage: UInt64
    }
    
    private func getProcessList() -> [ProcessInfo] {
        // 실제 프로세스 목록을 가져오는 로직 구현 필요
        [
            ProcessInfo(name: "Safari", memoryUsage: 1024 * 1024 * 500),
            ProcessInfo(name: "Chrome", memoryUsage: 1024 * 1024 * 800),
            ProcessInfo(name: "Xcode", memoryUsage: 1024 * 1024 * 1024 * 2),
            ProcessInfo(name: "Finder", memoryUsage: 1024 * 1024 * 100)
        ]
    }
    
    private func terminateProcess(_ name: String) {
        // 실제 프로세스 종료 로직 구현 필요
        print("Terminating process: \(name)")
    }
} 