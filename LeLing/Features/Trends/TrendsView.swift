import SwiftUI
import Charts

/// A3 · 趋势
struct TrendsView: View {
    @State private var metric = 0   // 0 心率 / 1 呼吸 / 2 跌倒风险

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Picker("指标", selection: $metric) {
                        Text("心率").tag(0)
                        Text("呼吸").tag(1)
                        Text("跌倒风险").tag(2)
                    }
                    .pickerStyle(.segmented)

                    // 折线图
                    VStack(alignment: .leading, spacing: 10) {
                        Text("心率 (次/分) · 近 7 天")
                            .font(.senior(.headline))
                            .foregroundStyle(LeLingColor.primaryText)
                        Chart(SampleData.heartTrend) { point in
                            LineMark(
                                x: .value("日", point.day),
                                y: .value("心率", point.value)
                            )
                            .lineStyle(StrokeStyle(lineWidth: 4))
                            .foregroundStyle(LeLingColor.accent)

                            PointMark(
                                x: .value("日", point.day),
                                y: .value("心率", point.value)
                            )
                            .foregroundStyle(LeLingColor.accent)
                        }
                        .chartYScale(domain: 60...85)
                        .frame(height: 200)
                    }
                    .seniorCard()

                    Text("本周平均 72，比上周 ↓3  🟢")
                        .font(.senior(.body))
                        .foregroundStyle(LeLingColor.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // 测量日历（简版一周）
                    VStack(alignment: .leading, spacing: 12) {
                        Text("📅 本周测量")
                            .font(.senior(.headline))
                            .foregroundStyle(LeLingColor.primaryText)
                        HStack(spacing: 10) {
                            ForEach(Array(zip(["一","二","三","四","五","六","日"], SampleData.weekColors)), id: \.0) { day, level in
                                VStack(spacing: 8) {
                                    Text(day)
                                        .font(.senior(.caption))
                                        .foregroundStyle(LeLingColor.secondaryText)
                                    Circle()
                                        .fill(level?.color ?? LeLingColor.divider)
                                        .frame(width: 22, height: 22)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .seniorCard()

                    NavigationLink {
                        ReportView()
                    } label: {
                        Label("生成本周健康报告", systemImage: "doc.text.fill")
                    }
                    .buttonStyle(SeniorPrimaryButtonStyle())
                }
                .padding()
            }
            .seniorScreen()
            .navigationTitle("趋势")
        }
    }
}

/// E1 · AI 健康周报
struct ReportView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("📄 6/8 — 6/14")
                    .font(.senior(.headline))
                    .foregroundStyle(LeLingColor.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 14) {
                    Text("\(SampleData.name) · 本周健康小结")
                        .font(.senior(.headline))
                        .foregroundStyle(LeLingColor.primaryText)
                    reportLine("心率平均 72，平稳", .good)
                    reportLine("跌倒风险良好", .good)
                    reportLine("周三呼吸略快，注意休息", .caution)
                    Text("建议：天气转热多喝水，每天测一次，坚持散步。")
                        .font(.senior(.body))
                        .foregroundStyle(LeLingColor.secondaryText)
                    Text("（健康筛查，非医疗诊断）")
                        .font(.senior(.caption))
                        .foregroundStyle(LeLingColor.secondaryText)
                }
                .seniorCard()

                Button { } label: {
                    Label("发给子女（微信 / 短信）", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(SeniorPrimaryButtonStyle())

                Button { } label: {
                    Label("导出 PDF", systemImage: "doc.fill")
                        .font(.senior(.headline))
                        .foregroundStyle(LeLingColor.accentDeep)
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .background(LeLingColor.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 18))
                }
            }
            .padding()
        }
        .seniorScreen()
        .navigationTitle("本周健康报告")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func reportLine(_ text: String, _ level: HealthLevel) -> some View {
        HStack(spacing: 10) {
            Text("•").foregroundStyle(LeLingColor.primaryText)
            Text(text)
                .font(.senior(.body))
                .foregroundStyle(LeLingColor.primaryText)
            Spacer()
            Circle().fill(level.color).frame(width: 14, height: 14)
        }
    }
}

#Preview {
    TrendsView()
}
