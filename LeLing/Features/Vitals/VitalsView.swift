import SwiftUI

// MARK: - C. 心率 / 呼吸自查（后摄手指法，真实测量）

/// C1 · 说明页
struct VitalsIntroView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                Image(systemName: "hand.point.up.left.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(LeLingColor.risk)
                    .padding(.top, 8)

                VStack(alignment: .leading, spacing: 14) {
                    Text("怎么做")
                        .font(.senior(.headline))
                        .foregroundStyle(LeLingColor.primaryText)
                    stepRow("①", "用食指轻轻盖住手机背面的摄像头和闪光灯")
                    stepRow("②", "力度稳住，别一会松一会紧")
                    stepRow("③", "保持不动约 30 秒，正常呼吸")
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Label("会打开闪光灯，属正常现象", systemImage: "flashlight.on.fill")
                    .font(.senior(.body))
                    .foregroundStyle(LeLingColor.accentDeep)

                NavigationLink {
                    VitalsMeasureView()
                } label: {
                    Text("开始测量")
                }
                .buttonStyle(SeniorPrimaryButtonStyle())
            }
            .padding()
        }
        .seniorScreen()
        .navigationTitle("心率 / 呼吸自查")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func stepRow(_ num: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(num)
                .font(.senior(.headline))
                .foregroundStyle(LeLingColor.accent)
            Text(text)
                .font(.senior(.body))
                .foregroundStyle(LeLingColor.primaryText)
        }
    }
}

/// C2/C3 · 测量中 + 结果（同一页随状态切换）
struct VitalsMeasureView: View {
    @EnvironmentObject private var store: LeLingStore
    @StateObject private var m = PPGMeasurer()
    @Environment(\.dismiss) private var dismiss
    @State private var saved = false

    var body: some View {
        VStack(spacing: 24) {
            switch m.phase {
            case .idle, .measuring: measuringUI
            case .done:             resultUI
            case .failed:           failedUI
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .seniorScreen()
        .navigationTitle("心率 / 呼吸")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { if m.phase == .idle { m.start() } }
        .onDisappear { m.cancel() }
    }

    // 测量中
    private var measuringUI: some View {
        VStack(spacing: 28) {
            Spacer()
            ZStack {
                Circle().stroke(LeLingColor.divider, lineWidth: 16)
                Circle()
                    .trim(from: 0, to: m.progress)
                    .stroke(LeLingColor.accent, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(Int(m.progress * 100))%")
                    .font(.senior(.title))
                    .foregroundStyle(LeLingColor.primaryText)
            }
            .frame(width: 200, height: 200)
            .animation(.linear(duration: 0.1), value: m.progress)

            if m.fingerOK {
                Label("测量中…请保持不动", systemImage: "heart.fill")
                    .font(.senior(.headline))
                    .foregroundStyle(LeLingColor.good)
            } else {
                Label("请把食指盖住背面摄像头", systemImage: "exclamationmark.triangle.fill")
                    .font(.senior(.headline))
                    .foregroundStyle(LeLingColor.caution)
            }

            Spacer()
            Button { dismiss() } label: {
                Text("取消")
                    .font(.senior(.headline))
                    .foregroundStyle(LeLingColor.secondaryText)
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(LeLingColor.cardSurface, in: RoundedRectangle(cornerRadius: 18))
            }
        }
    }

    // 结果
    private var resultUI: some View {
        VStack(spacing: 20) {
            HStack(spacing: 14) {
                bigVital(icon: "❤️", name: "心率", value: "\(m.heartRate)",
                         unit: "次/分", level: hrLevel(m.heartRate))
                bigVital(icon: "🫁", name: "呼吸", value: m.respiration > 0 ? "\(m.respiration)" : "—",
                         unit: "次/分", level: rrLevel(m.respiration))
            }

            Text("结果仅供参考，非医疗诊断。")
                .font(.senior(.caption))
                .foregroundStyle(LeLingColor.secondaryText)

            Spacer()

            Button {
                store.addVitals(heartRate: m.heartRate, respiration: m.respiration)
                saved = true
                dismiss()
            } label: {
                Label(saved ? "已保存" : "保存", systemImage: "square.and.arrow.down")
            }
            .buttonStyle(SeniorPrimaryButtonStyle())

            Button { m.reset(); m.start() } label: {
                Text("重新测一次")
                    .font(.senior(.headline))
                    .foregroundStyle(LeLingColor.accentDeep)
                    .frame(maxWidth: .infinity, minHeight: 60)
            }
        }
    }

    // 失败
    private var failedUI: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(LeLingColor.caution)
            Text("没测到，请重试")
                .font(.senior(.title))
                .foregroundStyle(LeLingColor.primaryText)
            Text("把食指盖住背面摄像头和闪光灯，力度稳住、保持不动再试一次。")
                .font(.senior(.body))
                .foregroundStyle(LeLingColor.secondaryText)
                .multilineTextAlignment(.center)
            Spacer()
            Button { m.reset(); m.start() } label: { Text("重新测一次") }
                .buttonStyle(SeniorPrimaryButtonStyle())
        }
    }

    // 等级判断（筛查级简单阈值）
    private func hrLevel(_ hr: Int) -> HealthLevel {
        (60...100).contains(hr) ? .good : .caution
    }
    private func rrLevel(_ rr: Int) -> HealthLevel {
        rr == 0 ? .caution : ((12...20).contains(rr) ? .good : .caution)
    }

    private func bigVital(icon: String, name: String, value: String, unit: String, level: HealthLevel) -> some View {
        VStack(spacing: 8) {
            Text("\(icon) \(name)")
                .font(.senior(.headline))
                .foregroundStyle(LeLingColor.primaryText)
            Text(value)
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(LeLingColor.primaryText)
            HStack(spacing: 5) {
                Text(unit).font(.senior(.caption)).foregroundStyle(LeLingColor.secondaryText)
                Circle().fill(level.color).frame(width: 12, height: 12)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .background(LeLingColor.cardSurface, in: RoundedRectangle(cornerRadius: 22))
    }
}

#Preview {
    NavigationStack { VitalsIntroView() }
}
