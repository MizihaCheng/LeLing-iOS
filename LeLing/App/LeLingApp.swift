import SwiftUI

@main
struct LeLingApp: App {
    @StateObject private var store = LeLingStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .tint(LeLingColor.accent)
        }
    }
}
