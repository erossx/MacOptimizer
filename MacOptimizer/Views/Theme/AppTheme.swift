import SwiftUI

enum AppTheme {
    static let primaryColor = Color.accentColor
    static let secondaryColor = Color(.secondaryLabelColor)
    static let backgroundColor = Color(.windowBackgroundColor)
    static let cardBackgroundColor = Color(.controlBackgroundColor)
    
    static let cornerRadius: CGFloat = 10
    static let padding: CGFloat = 16
    static let spacing: CGFloat = 12
    
    struct Animation {
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
        static let rotate = SwiftUI.Animation.linear(duration: 1).repeatForever(autoreverses: false)
    }
}

struct CardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(AppTheme.cardBackgroundColor)
            .cornerRadius(AppTheme.cornerRadius)
            .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.1),
                   radius: 5, x: 0, y: 2)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
} 