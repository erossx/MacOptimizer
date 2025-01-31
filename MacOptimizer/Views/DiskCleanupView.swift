import SwiftUI

struct DiskCleanupView: View {
    @State private var isScanning = false
    @State private var selectedItems = Set<String>()
    
    let cleanupItems = [
        CleanupItem(id: "cache", name: "시스템 캐시", size: "1.2 GB", icon: "folder.fill"),
        CleanupItem(id: "logs", name: "로그 파일", size: "450 MB", icon: "doc.fill"),
        CleanupItem(id: "downloads", name: "다운로드 폴더", size: "5.8 GB", icon: "arrow.down.circle.fill"),
        CleanupItem(id: "trash", name: "휴지통", size: "2.3 GB", icon: "trash.fill")
    ]
    
    var totalSelectedSize: String {
        "2.8 GB"  // 실제로는 선택된 항목들의 크기를 계산해야 함
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 헤더
            Text("디스크 정리")
                .font(.largeTitle)
                .bold()
            
            // 디스크 사용량 표시
            DiskUsageView()
            
            // 정리 항목 목록
            List(cleanupItems, selection: $selectedItems) { item in
                CleanupItemRow(item: item)
            }
            
            // 하단 작업 버튼
            HStack {
                if !selectedItems.isEmpty {
                    Text("\(selectedItems.count)개 항목 선택됨 (약 \(totalSelectedSize))")
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: scanDisk) {
                    Text("스캔")
                        .frame(width: 100)
                }
                .buttonStyle(.bordered)
                
                Button(action: cleanupSelected) {
                    Text("선택 항목 정리")
                        .frame(width: 150)
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedItems.isEmpty)
            }
            .padding()
        }
        .padding()
    }
    
    private func scanDisk() {
        // 디스크 스캔 로직 구현
    }
    
    private func cleanupSelected() {
        // 선택된 항목 정리 로직 구현
    }
}

struct CleanupItem: Identifiable, Hashable {
    let id: String
    let name: String
    let size: String
    let icon: String
}

struct CleanupItemRow: View {
    let item: CleanupItem
    
    var body: some View {
        HStack {
            Image(systemName: item.icon)
                .foregroundColor(.accentColor)
            
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                Text(item.size)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct DiskUsageView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("디스크 사용량")
                .font(.headline)
            
            GeometryReader { geometry in
                HStack(spacing: 2) {
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * 0.4)
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: geometry.size.width * 0.3)
                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: geometry.size.width * 0.2)
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: geometry.size.width * 0.1)
                }
            }
            .frame(height: 20)
            .cornerRadius(4)
            
            HStack {
                Label("시스템: 120GB", systemImage: "circle.fill")
                    .foregroundColor(.blue)
                Label("앱: 89GB", systemImage: "circle.fill")
                    .foregroundColor(.green)
                Label("문서: 56GB", systemImage: "circle.fill")
                    .foregroundColor(.orange)
                Label("여유: 35GB", systemImage: "circle.fill")
                    .foregroundColor(.gray)
            }
            .font(.caption)
        }
        .padding()
        .background(Color(.windowBackgroundColor))
        .cornerRadius(10)
    }
} 