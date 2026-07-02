import SwiftUI

// MARK: - D. 报平安 + 给子女的报告
//
// 双语气交汇点：
//   · 老人端：轻松邀请「把好消息告诉孩子」，老人不必读懂内容。
//   · 报告内容（发给子女）：**严肃科学语气 + 数字 + 🟢🟡🔴 分级**。
//   · 数字全部来自后台记录（LeLingStore），老人端别处一律不显示。
//
// UI 阶段：报告为屏内预览 + 文本 ShareLink。真 PDF 导出后续再接。

struct ReportShareView: View {
    @EnvironmentObject private var store: LeLingStore
    @State private var showReport = false

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                Text("💌")
                    .font(.system(size: 72))
                    .padding(.top, 8)

                Text("把这几天的好消息\n发给闺女，好吗？")
                    .font(.senior(.title))
                    .foregroundStyle(LeLingColor.primaryText)
                    .multilineTextAlignment(.center)

                Text("会生成一份健康小报告，\n孩子看了就安心啦～")
                    .font(.senior(.body))
                    .foregroundStyle(LeLingColor.secondaryText)
                    .multilineTextAlignment(.center)

                ShareLink(item: reportText) {
                    Label("发给女儿 王芳", systemImage: "square.and.arrow.up")
                        .font(.senior(.headline))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 64)
                        .background(LeLingColor.accent, in: RoundedRectangle(cornerRadius: 18))
                }

                Button {
                    withAnimation { showReport.toggle() }
                } label: {
                    Text(showReport ? "收起报告" : "看看要发的内容")
                        .font(.senior(.body))
                        .foregroundStyle(LeLingColor.accentDeep)
                }

                if showReport {
                    ClinicalReportCard(vitals: store.vitals.first, fall: store.falls.first)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding()
        }
        .seniorScreen()
        .navigationTitle("报个平安")
        .navigationBarTitleDisplayMode(.inline)
    }

    /// 分享出去的纯文本小结（严肃语气）。
    private var reportText: String {
        let hr = store.vitals.first.map { "\($0.heartRate) bpm" } ?? "—"
        let rr = store.vitals.first.map { "\($0.respiration) 次/分" } ?? "—"
        let fall = store.falls.first.map { "坐站 \($0.reps) 次/30秒（\(faLevel($0.level).label)）" } ?? "—"
        return """
        【\(SampleData.name) · 健康小结】
        心率：\(hr)
        呼吸：\(rr)
        下肢力量：\(fall)
        —— 由「乐龄守护」生成，为健康筛查参考，非医疗诊断。数据仅存于本机。
        """
    }
}

/// 给子女看的临床卡片（**这里才出现数字 + 分级**）。
struct ClinicalReportCard: View {
    let vitals: VitalsRecord?
    let fall: FallRiskRecord?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(SampleData.name) · 健康周报")
                .font(.senior(.headline))
                .foregroundStyle(LeLingColor.primaryText)

            row("❤️ 心率", vitals.map { "\($0.heartRate) bpm" } ?? "暂无", hrLevel(vitals?.heartRate))
            Divider().background(LeLingColor.divider)
            row("🫁 呼吸", vitals.map { "\($0.respiration) 次/分" } ?? "暂无", rrLevel(vitals?.respiration))
            Divider().background(LeLingColor.divider)
            row("🦵 下肢力量", fall.map { "坐站 \($0.reps) 次/30秒" } ?? "暂无", fall.map { faLevel($0.level) })

            Text("本报告为健康筛查参考，非医疗诊断，不替代医生。数据仅存于长辈手机本机。")
                .font(.senior(.caption))
                .foregroundStyle(LeLingColor.secondaryText)
                .padding(.top, 4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LeLingColor.cardSurface, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20).strokeBorder(LeLingColor.divider, lineWidth: 1)
        )
    }

    private func row(_ name: String, _ value: String, _ level: HealthLevel?) -> some View {
        HStack {
            Text(name).font(.senior(.body)).foregroundStyle(LeLingColor.primaryText)
            Spacer()
            Text(value).font(.senior(.body)).foregroundStyle(LeLingColor.primaryText)
            if let level { LevelTag(level: level).padding(.leading, 6) }
        }
    }

    private func hrLevel(_ hr: Int?) -> HealthLevel? {
        guard let hr else { return nil }
        return (60...100).contains(hr) ? .good : .caution
    }
    private func rrLevel(_ rr: Int?) -> HealthLevel? {
        guard let rr, rr > 0 else { return nil }
        return (12...20).contains(rr) ? .good : .caution
    }
}

/// 存储字符串 → HealthLevel。
func faLevel(_ s: String) -> HealthLevel {
    switch s {
    case "risk":    return .risk
    case "caution": return .caution
    default:        return .good
    }
}

#Preview {
    NavigationStack { ReportShareView() }
        .environmentObject(LeLingStore())
}
