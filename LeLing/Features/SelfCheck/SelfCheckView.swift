import SwiftUI

/// A2 · 自查
struct SelfCheckView: View {
    var body: some View {
        NavigationStack {
            content
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 18) {
                NavigationLink {
                    FallRiskIntroView()
                } label: {
                    SelfCheckEntryCard(
                        icon: "figure.stand",
                        star: true,
                        title: "跌倒风险评估",
                        subtitle: "对着摄像头做坐站测试，评估跌倒风险"
                    )
                }

                NavigationLink {
                    VitalsIntroView()
                } label: {
                    SelfCheckEntryCard(
                        icon: "heart.fill",
                        star: false,
                        title: "心率 / 呼吸自查",
                        subtitle: "拍脸约 30 秒，测心率与呼吸"
                    )
                }

                NavigationLink {
                    AllInOneResultView()
                } label: {
                    Label("一键全部测（约 2 分钟）", systemImage: "bolt.fill")
                        .font(.senior(.headline))
                        .foregroundStyle(LeLingColor.accentDeep)
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .background(LeLingColor.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 18))
                }

                // 最近记录
                VStack(alignment: .leading, spacing: 10) {
                    Text("最近记录")
                        .font(.senior(.headline))
                        .foregroundStyle(LeLingColor.primaryText)
                    recentRow(time: "今天 9:20", text: "心率 72 · 跌倒 良好", level: .good)
                    recentRow(time: "昨天 9:05", text: "心率 75 · 跌倒 注意", level: .caution)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)

                Text("本应用为健康筛查与趋势提示，非医疗诊断。")
                    .font(.senior(.caption))
                    .foregroundStyle(LeLingColor.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
            .padding()
        }
        .seniorScreen()
        .navigationTitle("健康自查")
    }

    private func recentRow(time: String, text: String, level: HealthLevel) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(time)
                    .font(.senior(.caption))
                    .foregroundStyle(LeLingColor.secondaryText)
                Text(text)
                    .font(.senior(.body))
                    .foregroundStyle(LeLingColor.primaryText)
            }
            Spacer()
            Circle().fill(level.color).frame(width: 16, height: 16)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 18)
        .background(LeLingColor.cardSurface, in: RoundedRectangle(cornerRadius: 18))
    }
}

struct SelfCheckEntryCard: View {
    let icon: String
    let star: Bool
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 18) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(LeLingColor.accent)
                .frame(width: 56)
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.senior(.headline))
                        .foregroundStyle(LeLingColor.primaryText)
                    if star { Text("⭐️") }
                }
                Text(subtitle)
                    .font(.senior(.caption))
                    .foregroundStyle(LeLingColor.secondaryText)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.headline)
                .foregroundStyle(LeLingColor.secondaryText)
        }
        .seniorCard()
    }
}

#Preview {
    NavigationStack { SelfCheckView() }
}
