import SwiftUI

struct ContentView: View {
    @State private var selectedTab: SidebarItem = .dashboard
    
    var body: some View {
        NavigationSplitView {
            Sidebar(selection: $selectedTab)
        } detail: {
            DetailView(selectedTab: selectedTab)
        }
        .navigationSplitViewStyle(.balanced)
    }
} 