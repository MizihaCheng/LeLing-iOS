import SwiftUI

/// D1 · 一键全部测 · 汇总结果
struct AllInOneResultView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("✅ 全部测完了！")
                    .font(.senior(.title))
                    .foregroundStyle(LeLingColor.primaryText)
                    .padding(.top, 8)

                VStack(spacing: 0) {
                    summaryRow(icon: "❤️", name: "心率", value: "72 次/分", level: .good)
                    Divider().background(LeLingColor.divider)
                    summaryRow(icon: "🫁", name: "呼吸", value: "16 次/分", level: .good)
                    Divider().background(LeLingColor.divider)
                    summaryRow(icon: "🧍", name: "跌倒", value: "良好", level: .good)
                }
                .background(LeLingColor.cardSurface, in: RoundedRectangle(cornerRadius: 24))

                VStack(alignment: .leading, spacing: 10) {
                    Text("AI 小结")
                        .font(.senior(.headline))
                        .foregroundStyle(LeLingColor.primaryText)
                    Text("今天各项都不错，保持规律作息，记得多走动。")
                        .font(.senior(.body))
                        .foregroundStyle(LeLingColor.secondaryText)
                }
                .seniorCard()

                HStack(spacing: 14) {
                    Button { } label: {
                        Label("保存", systemImage: "square.and.arrow.down")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SeniorPrimaryButtonStyle())

                    Button { } label: {
                        Label("发子女", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SeniorPrimaryButtonStyle())
                }
            }
            .padding()
        }
        .seniorScreen()
        .navigationTitle("今日自查 · 完成")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func summaryRow(icon: String, name: String, value: String, level: HealthLevel) -> some View {
        HStack {
            Text(icon).font(.system(size: 26))
            Text(name)
                .font(.senior(.body))
                .foregroundStyle(LeLingColor.primaryText)
            Spacer()
            Text(value)
                .font(.senior(.body))
                .foregroundStyle(LeLingColor.primaryText)
            Circle().fill(level.color).frame(width: 16, height: 16)
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 20)
    }
}

#Preview {
    NavigationStack { AllInOneResultView() }
}
