import SwiftUI

struct OneClickOptimizeView: View {
    @StateObject private var optimizer = SystemOptimizer()
    @Environment(\.colorScheme) var colorScheme
    
    private let rotationAnimation = Animation.linear(duration: 1.0).repeatForever(autoreverses: false)
    
    var body: some View {
        VStack(spacing: AppTheme.spacing * 2) {
            // 상단 설명
            VStack(alignment: .leading, spacing: AppTheme.spacing) {
                Text("원클릭 최적화")
                    .font(.largeTitle)
                    .bold()
                Text("시스템 캐시, 로그 파일, 다운로드 폴더를 정리하고 메모리를 최적화합니다.")
                    .foregroundColor(.secondary)
            }
            
            // 최적화 상태 카드
            VStack(spacing: AppTheme.spacing) {
                Image(systemName: optimizer.isOptimizing ? "arrow.triangle.2.circlepath.circle.fill" : "bolt.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.primaryColor)
                    .rotationEffect(.degrees(optimizer.isOptimizing ? 360 : 0))
                    .animation(optimizer.isOptimizing ? rotationAnimation : .default, value: optimizer.isOptimizing)
                
                Text(optimizer.currentTask)
                    .font(.headline)
                    .transition(.opacity)
                
                if optimizer.isOptimizing {
                    ProgressView(value: optimizer.progress)
                        .progressViewStyle(.linear)
                        .frame(width: 200)
                        .transition(.opacity)
                }
            }
            .cardStyle()
            
            // 최적화 버튼
            Button(action: {
                withAnimation {
                    Task(priority: .userInitiated) {
                        try? await optimizer.startOptimization()
                    }
                }
            }) {
                Text(optimizer.isOptimizing ? "최적화 중..." : "지금 최적화")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 44)
                    .background(optimizer.isOptimizing ? Color.gray : AppTheme.primaryColor)
                    .cornerRadius(AppTheme.cornerRadius)
            }
            .buttonStyle(.plain)
            .disabled(optimizer.isOptimizing)
            .accessibility(label: optimizer.isOptimizing ? "최적화 진행 중" : "시스템 최적화 시작",
                          hint: optimizer.isOptimizing ? "최적화가 진행 중입니다" : "클릭하여 시스템 최적화를 시작합니다")
            
            Spacer()
        }
        .padding(AppTheme.padding * 2)
        .background(AppTheme.backgroundColor)
        .animation(.default, value: optimizer.isOptimizing)
    }
} 