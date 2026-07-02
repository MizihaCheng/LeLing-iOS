import SwiftUI

/// A2 · 回顾（温和回看）
/// **不放折线趋势图**（那只进给子女的报告）。老人端只看到发芽/开花的日历 + 正向小结。
struct ReviewView: View {
    private var activeDays: Int { SampleData.monthActivity.filter { $0 }.count }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    // 整体正向定性
                    VStack(alignment: .leading, spacing: 8) {
                        Text("这几天，你都挺好的 🌼")
                            .font(.senior(.title))
                            .foregroundStyle(LeLingColor.primaryText)
                        Text("这个月活动了 \(activeDays) 天，很棒～")
                            .font(.senior(.body))
                            .foregroundStyle(LeLingColor.secondaryText)
                    }

                    // 发芽/开花日历（无颜色分级）
                    VStack(alignment: .leading, spacing: 14) {
                        Text("📅 这个月")
                            .font(.senior(.headline))
                            .foregroundStyle(LeLingColor.primaryText)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 14) {
                            ForEach(Array(SampleData.monthActivity.enumerated()), id: \.offset) { _, active in
                                Text(active ? "🌼" : "·")
                                    .font(.system(size: active ? 24 : 28))
                                    .foregroundStyle(active ? .primary : LeLingColor.secondaryText.opacity(0.5))
                                    .frame(maxWidth: .infinity, minHeight: 34)
                            }
                        }

                        Text("🌼 = 那天活动过 · 空着也没关系，随时可以开始")
                            .font(.senior(.caption))
                            .foregroundStyle(LeLingColor.secondaryText)
                    }
                    .seniorCard()

                    // 报平安（本页主行动）
                    NavigationLink {
                        ReportShareView()
                    } label: {
                        Label("给闺女报个平安", systemImage: "heart.fill")
                    }
                    .buttonStyle(SeniorPrimaryButtonStyle())
                }
                .padding()
            }
            .seniorScreen()
            .navigationTitle("回顾")
        }
    }
}

#Preview {
    ReviewView()
        .environmentObject(LeLingStore())
}
