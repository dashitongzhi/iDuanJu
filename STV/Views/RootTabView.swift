import SwiftUI

/// Four independent navigation stacks hosted by the system tab bar.
/// Pushed pages hide the tab bar; returning to a root restores it.
struct RootTabView: View {
    @State private var tab = Int(ProcessInfo.processInfo.environment["STV_TAB"] ?? "") ?? 0
    @State private var paths = [NavigationPath(), NavigationPath(), NavigationPath(), NavigationPath()]
    var body: some View {
        TabView(selection: $tab) {
            Tab(value: 0) {
                Stack(path: $paths[0]) { HomeView() }
            } label: {
                Label("首页", systemImage: "play.house.fill").accessibilityIdentifier("tab.0")
            }
            Tab(value: 1) {
                Stack(path: $paths[1]) { SearchView() }
            } label: {
                Label("搜索", systemImage: "magnifyingglass").accessibilityIdentifier("tab.1")
            }
            Tab(value: 2) {
                Stack(path: $paths[2]) { CategoryView() }
            } label: {
                Label("找剧", systemImage: "square.grid.2x2.fill").accessibilityIdentifier("tab.2")
            }
            Tab(value: 3) {
                Stack(path: $paths[3]) { ProfileView() }
            } label: {
                Label("我的", systemImage: "person.crop.circle.fill").accessibilityIdentifier("tab.3")
            }
        }
        .tint(STVTheme.accent)
        .onAppear {
            Router.handler = { r in paths[tab].append(r) }
            #if DEBUG
            if ProcessInfo.processInfo.environment["STV_TD_OPEN"] == "1" { Router.push(.tdlib) }
            #endif
        }
        // Cold start: restore a saved TDLib login (no network login, nothing is sent).
        .task { await TDLibService.shared.bootstrap() }
    }
}
private struct Stack<V: View>: View {
    @Binding var path: NavigationPath
    @ViewBuilder var content: V
    @Namespace private var ns
    var body: some View {
        NavigationStack(path: $path) {
            content.routes()
        }
        .toolbar(path.isEmpty ? .visible : .hidden, for: .tabBar)
        .environment(\.zoomNS, ns)
    }
}
