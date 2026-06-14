import SwiftUI

/// A1 · 首页
struct HomeView: View {
    var onStartCheck: () -> Void = {}
    @State private var showSOS = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 问候 + AI 一句话提示
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(SampleData.name)，早上好 👋")
                            .font(.senior(.title))
                            .foregroundStyle(LeLingColor.primaryText)
                        Text(SampleData.greetingTip)
                            .font(.senior(.body))
                            .foregroundStyle(LeLingColor.secondaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // 大号紧急呼叫按钮（红色，醒目）
                    Button {
                        showSOS = true
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 32, weight: .bold))
                            Text("紧急呼叫")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 78)
                        .background(LeLingColor.risk, in: RoundedRectangle(cornerRadius: 22))
                    }

                    // 超大主按钮
                    Button {
                        onStartCheck()
                    } label: {
                        Label("开始今日自查", systemImage: "play.circle.fill")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 80)
                            .background(LeLingColor.accent, in: RoundedRectangle(cornerRadius: 22))
                    }

                    // 最近一次结果
                    HStack(spacing: 12) {
                        VitalMiniCard(icon: "❤️", value: "72", unit: "次/分", level: .good)
                        VitalMiniCard(icon: "🫁", value: "16", unit: "次/分", level: .good)
                        VitalMiniCard(icon: "🧍", value: "良好", unit: "跌倒", level: .good)
                    }
                    HStack {
                        Text("最近一次 · 今天 9:20")
                            .font(.senior(.caption))
                            .foregroundStyle(LeLingColor.secondaryText)
                        Spacer()
                    }

                    // 今日提醒
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🔔 今日提醒")
                            .font(.senior(.headline))
                            .foregroundStyle(LeLingColor.primaryText)
                        HStack {
                            Text("💊 该吃降压药了")
                                .font(.senior(.body))
                                .foregroundStyle(LeLingColor.primaryText)
                            Spacer()
                            Text("上午 8:00")
                                .font(.senior(.body))
                                .foregroundStyle(LeLingColor.secondaryText)
                        }
                        .seniorCard()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
            .seniorScreen()
            .navigationTitle("乐龄守护")
            .fullScreenCover(isPresented: $showSOS) {
                SOSView()
            }
        }
    }
}

#Preview {
    HomeView()
}
