import SwiftUI

/// 适老 Tab 外壳（v2）：3 个大 Tab —— 今天 / 回顾 / 我的。
/// 全局「联系家人」不占 Tab，从「今天」右上角进（见 TodayView）。
struct ContentView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("今天", systemImage: "sun.max.fill") }

            ReviewView()
                .tabItem { Label("回顾", systemImage: "leaf.fill") }

            MineView()
                .tabItem { Label("我的", systemImage: "person.crop.circle.fill") }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LeLingStore())
}
