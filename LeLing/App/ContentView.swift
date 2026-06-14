import SwiftUI

/// 适老化 Tab 外壳：图标大、文字大、四个主入口扁平直达。
struct ContentView: View {
    @State private var tab = 0

    var body: some View {
        TabView(selection: $tab) {
            HomeView(onStartCheck: { tab = 1 })
                .tabItem { Label("首页", systemImage: "house.fill") }
                .tag(0)

            SelfCheckView()
                .tabItem { Label("自查", systemImage: "heart.text.square.fill") }
                .tag(1)

            TrendsView()
                .tabItem { Label("趋势", systemImage: "chart.xyaxis.line") }
                .tag(2)

            ProfileView()
                .tabItem { Label("我的", systemImage: "person.crop.circle.fill") }
                .tag(3)
        }
    }
}

#Preview {
    ContentView()
}
