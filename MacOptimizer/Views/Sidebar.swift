import SwiftUI

struct Sidebar: View {
    @Binding var selection: SidebarItem
    
    var body: some View {
        List(SidebarItem.allCases, id: \.self, selection: $selection) { item in
            NavigationLink(value: item) {
                Label(item.rawValue, systemImage: item.iconName)
            }
        }
        .listStyle(.sidebar)
    }
} 