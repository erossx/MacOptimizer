import SwiftUI

struct MemoryView: View {
    @State private var memoryUsage = 0.65  // 65% 사용 중
    @State private var isOptimizing = false
    @State private var processes = [
        ProcessItem(name: "Xcode", memory: "2.4 GB", cpu: "12%"),
        ProcessItem(name: "Chrome", memory: "1.8 GB", cpu: "8%"),
        ProcessItem(name: "Finder", memory: "380 MB", cpu: "2%"),
        ProcessItem(name: "Terminal", memory: "120 MB", cpu: "1%")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // 메모리 상태
            VStack {
                Text("메모리 상태")
                    .font(.largeTitle)
                    .bold()
                
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .trim(from: 0, to: memoryUsage)
                        .stroke(memoryUsage > 0.8 ? Color.red : Color.blue, lineWidth: 20)
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                    
                    VStack {
                        Text("\(Int(memoryUsage * 100))%")
                            .font(.system(size: 40, weight: .bold))
                        Text("사용 중")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                
                Button(action: optimizeMemory) {
                    HStack {
                        Image(systemName: "bolt.fill")
                        Text("메모리 최적화")
                    }
                    .frame(width: 200, height: 44)
                    .foregroundColor(.white)
                    .background(Color.accentColor)
                    .cornerRadius(8)
                }
                .disabled(isOptimizing)
            }
            
            // 프로세스 목록
            VStack(alignment: .leading) {
                Text("실행 중인 프로세스")
                    .font(.headline)
                    .padding(.bottom, 5)
                
                ForEach(processes) { process in
                    ProcessRow(process: process)
                }
            }
            .padding()
            .background(Color(.windowBackgroundColor))
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
    }
    
    private func optimizeMemory() {
        isOptimizing = true
        
        // 최적화 시뮬레이션
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            memoryUsage = 0.45  // 메모리 사용량 감소
            isOptimizing = false
        }
    }
}

struct ProcessItem: Identifiable {
    let id = UUID()
    let name: String
    let memory: String
    let cpu: String
}

struct ProcessRow: View {
    let process: ProcessItem
    
    var body: some View {
        HStack {
            Image(systemName: "app.fill")
                .foregroundColor(.accentColor)
            
            Text(process.name)
                .frame(width: 100, alignment: .leading)
            
            Spacer()
            
            Text(process.memory)
                .frame(width: 80)
                .foregroundColor(.secondary)
            
            Text(process.cpu)
                .frame(width: 60)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
} 