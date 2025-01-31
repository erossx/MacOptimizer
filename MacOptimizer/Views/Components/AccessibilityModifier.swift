import SwiftUI

struct AccessibilityModifier: ViewModifier {
    let label: String
    let hint: String
    
    func body(content: Content) -> some View {
        content
            .accessibilityLabel(label)
            .accessibilityHint(hint)
    }
}

extension View {
    func accessibility(label: String, hint: String) -> some View {
        modifier(AccessibilityModifier(label: label, hint: hint))
    }
} 