import SwiftUI

// MARK: - 静一静（心率 / 呼吸 · PPG 引擎已现成）
//
// 老人端像一次呼吸放松：**不显示 % 进度压力、不显示 bpm 数字**，
// 只给暖话。心率/呼吸数字存后台、进报告。
// 引擎 = PPGMeasurer（后摄手指法）；模拟器下自动跑假测量。

// MARK: C1 · 说明页

struct CalmIntroView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                Text("🌿")
                    .font(.system(size: 72))
                    .padding(.top, 8)

                Text("跟着呼吸，放松一下下")
                    .font(.senior(.title))
                    .foregroundStyle(LeLingColor.primaryText)

                VStack(alignment: .leading, spacing: 14) {
                    stepRow("①", "用食指轻轻盖住背面的摄像头")
                    stepRow("②", "稳稳地，别一会松一会紧")
                    stepRow("③", "跟着圈圈慢慢呼吸约 30 秒")
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Label("会亮一下灯，别担心，正常的", systemImage: "flashlight.on.fill")
                    .font(.senior(.body))
                    .foregroundStyle(LeLingColor.accentDeep)

                NavigationLink {
                    CalmSessionView()
                } label: {
                    Text("好，静一静")
                }
                .buttonStyle(SeniorPrimaryButtonStyle())
            }
            .padding()
        }
        .seniorScreen()
        .navigationTitle("静一静")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func stepRow(_ num: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(num).font(.senior(.headline)).foregroundStyle(LeLingColor.accent)
            Text(text).font(.senior(.body)).foregroundStyle(LeLingColor.primaryText)
        }
    }
}

// MARK: C2/C3 · 呼吸引导中 + 做完（同页随状态切换）

struct CalmSessionView: View {
    @EnvironmentObject private var store: LeLingStore
    @StateObject private var m = PPGMeasurer()
    @Environment(\.dismiss) private var dismiss
    @State private var saved = false
    @State private var breatheIn = false

    var body: some View {
        VStack(spacing: 24) {
            switch m.phase {
            case .idle, .measuring: breathingUI
            case .done:             doneUI
            case .failed:           failedUI
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .seniorScreen()
        .navigationTitle("静一静")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { if m.phase == .idle { m.start() } }
        .onDisappear { m.cancel() }
        .onChange(of: m.phase) { _, newPhase in
            if newPhase == .done && !saved {
                saved = true
                store.addVitals(heartRate: m.heartRate, respiration: m.respiration)
            }
        }
    }

    // C2 呼吸引导（涨缩圆，无 % 压力）
    private var breathingUI: some View {
        VStack(spacing: 28) {
            Spacer()
            ZStack {
                Circle()
                    .fill(LeLingColor.accent.opacity(0.12))
                    .frame(width: 260, height: 260)
                Circle()
                    .fill(LeLingColor.accent.opacity(0.22))
                    .frame(width: 200, height: 200)
                    .scaleEffect(breatheIn ? 1.15 : 0.85)
                Text(breatheIn ? "吸气" : "呼气")
                    .font(.senior(.title))
                    .foregroundStyle(LeLingColor.accentDeep)
            }
            .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: breatheIn)
            .onAppear { breatheIn = true }

            if m.fingerOK {
                Label("跟着一起呼吸…保持不动", systemImage: "heart.fill")
                    .font(.senior(.headline))
                    .foregroundStyle(LeLingColor.good)
            } else {
                Label("请把食指盖住背面摄像头", systemImage: "hand.point.up.left.fill")
                    .font(.senior(.headline))
                    .foregroundStyle(LeLingColor.caution)
            }

            Spacer()

            Button { dismiss() } label: {
                Text("先不测了")
                    .font(.senior(.headline))
                    .foregroundStyle(LeLingColor.secondaryText)
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(LeLingColor.cardSurface, in: RoundedRectangle(cornerRadius: 18))
            }
        }
    }

    // C3 做完（暖话，无数字）
    private var doneUI: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("💗")
                .font(.system(size: 80))
            Text("心跳很平稳呢，真好 😊")
                .font(.senior(.title))
                .foregroundStyle(LeLingColor.primaryText)
                .multilineTextAlignment(.center)
            Text("您今天状态不错，\n继续保持好心情～")
                .font(.senior(.body))
                .foregroundStyle(LeLingColor.secondaryText)
                .multilineTextAlignment(.center)

            Spacer()

            NavigationLink {
                ReportShareView()
            } label: {
                Label("把好消息告诉闺女", systemImage: "heart.fill")
            }
            .buttonStyle(SeniorPrimaryButtonStyle())

            Button { m.reset(); m.start() } label: {
                Text("再测一次")
                    .font(.senior(.headline))
                    .foregroundStyle(LeLingColor.accentDeep)
                    .frame(maxWidth: .infinity, minHeight: 60)
            }
        }
    }

    // 失败（温柔重试，不报错）
    private var failedUI: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("🌱").font(.system(size: 72))
            Text("没测到，咱再来一次")
                .font(.senior(.title))
                .foregroundStyle(LeLingColor.primaryText)
            Text("把食指轻轻盖住背面摄像头和闪光灯，\n稳住、别动，再试一次～")
                .font(.senior(.body))
                .foregroundStyle(LeLingColor.secondaryText)
                .multilineTextAlignment(.center)
            Spacer()
            Button { m.reset(); m.start() } label: { Text("再来一次") }
                .buttonStyle(SeniorPrimaryButtonStyle())
            Button { dismiss() } label: {
                Text("回去")
                    .font(.senior(.headline))
                    .foregroundStyle(LeLingColor.secondaryText)
                    .frame(maxWidth: .infinity, minHeight: 60)
            }
        }
    }
}

#Preview {
    NavigationStack { CalmIntroView() }
        .environmentObject(LeLingStore())
}
