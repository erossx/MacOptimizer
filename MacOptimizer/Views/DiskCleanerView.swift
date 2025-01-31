import SwiftUI

struct DiskCleanerView: View {
    @StateObject private var systemMonitor = SystemMonitor()
    @State private var isScanning = false
    @State private var selectedItems: Set<String> = []
    @State private var scanResults: [CleanupItem] = []
    
    struct CleanupItem: Identifiable, Hashable {
        let id = UUID()
        let path: String
        let size: Int64
        let type: CleanupType
        
        static func == (lhs: CleanupItem, rhs: CleanupItem) -> Bool {
            lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    enum CleanupType: String {
        case cache = "캐시 파일"
        case logs = "로그 파일"
        case downloads = "다운로드"
        case trash = "휴지통"
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // 상단 디스크 상태 표시
            HStack {
                VStack(alignment: .leading) {
                    Text("디스크 상태")
                        .font(.headline)
                    Text("여유 공간: \(formatBytes(Int64(systemMonitor.diskUsage.free)))")
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: startScan) {
                    Label("스캔 시작", systemImage: "magnifyingglass")
                }
                .disabled(isScanning)
            }
            .padding()
            .background(Color(.windowBackgroundColor))
            .cornerRadius(10)
            
            if isScanning {
                ProgressView("스캔 중...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else if !scanResults.isEmpty {
                // 스캔 결과 목록
                List(selection: $selectedItems) {
                    ForEach(CleanupType.allCases, id: \.self) { type in
                        let items = scanResults.filter { $0.type == type }
                        if !items.isEmpty {
                            Section(header: Text(type.rawValue)) {
                                ForEach(items) { item in
                                    HStack {
                                        Text(item.path)
                                        Spacer()
                                        Text(formatBytes(Int64(item.size)))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(InsetListStyle())
                
                // 정리 버튼
                Button(action: cleanupSelected) {
                    Label("선택 항목 정리", systemImage: "trash")
                }
                .disabled(selectedItems.isEmpty)
            } else {
                // 초기 상태 또는 스캔 결과 없음
                VStack(spacing: 10) {
                    Image(systemName: "internaldrive")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("스캔을 시작하여 정리 가능한 항목을 찾아보세요.")
                        .foregroundColor(.secondary)
                }
                .frame(maxHeight: .infinity)
            }
        }
        .padding()
    }
    
    private func startScan() {
        isScanning = true
        scanResults.removeAll()
        selectedItems.removeAll()
        
        // 실제 스캔 로직은 별도 클래스로 구현
        Task {
            // 임시 데모 데이터
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            await MainActor.run {
                scanResults = [
                    CleanupItem(path: "~/Library/Caches", size: 1024 * 1024 * 500, type: .cache),
                    CleanupItem(path: "~/Library/Logs", size: 1024 * 1024 * 200, type: .logs),
                    CleanupItem(path: "~/Downloads", size: 1024 * 1024 * 1024 * 2, type: .downloads),
                    CleanupItem(path: "~/.Trash", size: 1024 * 1024 * 800, type: .trash)
                ]
                isScanning = false
            }
        }
    }
    
    private func cleanupSelected() {
        // 실제 정리 로직 구현
        Task {
            for itemID in selectedItems {
                if let item = scanResults.first(where: { $0.id.uuidString == itemID }) {
                    // 실제 파일 삭제 로직 구현
                    print("Cleaning up: \(item.path)")
                }
            }
            // 정리 완료 후 재스캔
            startScan()
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

extension DiskCleanerView.CleanupType: CaseIterable {} 
