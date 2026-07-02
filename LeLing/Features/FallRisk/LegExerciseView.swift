import SwiftUI
import Combine   // @Published / ObservableObject 来自 Combine，需显式 import

// MARK: - 腿脚操（椅子坐站，⭐️ demo 主角）
//
// 老人端只见陪伴与治愈动效（开花），**不见次数成绩/倒计时/分级**。
// 后台算 CST 指标+分级 → 只写库、只进报告。
//
// ⚠️ 当前为 UI 阶段：活动推进用「模拟坐站」驱动（见 LegSession）。
//    真机接入 Vision（VNDetectHumanBodyPoseRequest）坐站检测后，
//    用真实 rep 事件替换 LegSession.tickActive 里的模拟计数即可。
//    实现规格见 实现规格-腿脚操Vision坐站.md。

// MARK: 会话状态机（模拟版）

@MainActor
final class LegSession: ObservableObject {
    enum Phase { case preparing, active, done }

    @Published var phase: Phase = .preparing
    @Published var countdown = 3
    @Published var reps = 0

    let duration = 30
    private var elapsed = 0
    private var timer: Timer?

    /// 后台结果（供报告/存储，老人端不显示）。
    private(set) var level: HealthLevel = .good

    func start() {
        timer?.invalidate()
        phase = .preparing
        countdown = 3
        reps = 0
        elapsed = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tickCountdown() }
        }
    }

    private func tickCountdown() {
        countdown -= 1
        if countdown <= 0 { beginActive() }
    }

    private func beginActive() {
        timer?.invalidate()
        phase = .active
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tickActive() }
        }
    }

    private func tickActive() {
        elapsed += 1
        // 模拟：约每 2.5 秒完成一次坐站（真机由 Vision 检测替换）
        reps = min(Int(Double(elapsed) / 2.5), 99)
        if elapsed >= duration { finish() }
    }

    /// 提前停也出结果——绝不判「失败」。
    func stopEarly() { finish() }

    private func finish() {
        guard phase == .active else { return }
        timer?.invalidate(); timer = nil
        level = reps >= 12 ? .good : (reps >= 8 ? .caution : .risk)   // 占位阈值，待接 CST 常模
        phase = .done
    }

    func cancel() { timer?.invalidate(); timer = nil }
}

// MARK: B1 · 说明页

struct LegExerciseIntroView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                CameraPlaceholder(caption: "找把稳当的椅子 · 手机靠稳能看到您")
                    .frame(height: 180)

                VStack(alignment: .leading, spacing: 14) {
                    Text("咱们一起活动活动腿脚")
                        .font(.senior(.headline))
                        .foregroundStyle(LeLingColor.primaryText)
                    stepRow("①", "找把稳当的椅子坐下")
                    stepRow("②", "手机靠稳，能看到您就行")
                    stepRow("③", "听我的，慢慢站起来、坐下")
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Label("全程有我陪您、给您提示", systemImage: "speaker.wave.2.fill")
                    .font(.senior(.body))
                    .foregroundStyle(LeLingColor.accentDeep)

                NavigationLink {
                    LegExerciseFramingView()
                } label: {
                    Text("好，我们开始")
                }
                .buttonStyle(SeniorPrimaryButtonStyle())

                Text("不着急，随时可以停下来 🌿")
                    .font(.senior(.caption))
                    .foregroundStyle(LeLingColor.secondaryText)
            }
            .padding()
        }
        .seniorScreen()
        .navigationTitle("腿脚操")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func stepRow(_ num: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(num).font(.senior(.headline)).foregroundStyle(LeLingColor.accent)
            Text(text).font(.senior(.body)).foregroundStyle(LeLingColor.primaryText)
        }
    }
}

// MARK: B2 · 取景对位

struct LegExerciseFramingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 24).fill(Color.black.opacity(0.82))
                VStack(spacing: 8) {
                    Text("🪑")
                        .font(.system(size: 96))
                    Image(systemName: "figure.stand")
                        .font(.system(size: 88))
                        .foregroundStyle(.white.opacity(0.55))
                    Text("坐这里")
                        .font(.senior(.caption))
                        .foregroundStyle(.white.opacity(0.65))
                }
                .padding(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [10, 8]))
                        .foregroundStyle(.white.opacity(0.7))
                )
            }
            .frame(maxWidth: .infinity)
            .frame(height: 360)

            Label("往后坐一点，让我看到您 😊", systemImage: "hand.wave.fill")
                .font(.senior(.headline))
                .foregroundStyle(LeLingColor.accentDeep)

            Text("坐好了就可以开始～")
                .font(.senior(.caption))
                .foregroundStyle(LeLingColor.secondaryText)

            Spacer()

            NavigationLink {
                LegExerciseSessionView()
            } label: {
                Text("我坐好了，开始")
            }
            .buttonStyle(SeniorPrimaryButtonStyle())
        }
        .padding()
        .seniorScreen()
        .navigationTitle("坐到框里")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: B3/B4/B5 · 准备 / 活动中 / 做完（同页随状态切换）

struct LegExerciseSessionView: View {
    @EnvironmentObject private var store: LeLingStore
    @StateObject private var s = LegSession()
    @Environment(\.dismiss) private var dismiss
    @State private var saved = false

    /// 治愈动效用的花草鸟
    private let garden = ["🌸", "🌿", "🐦", "🌼", "🌷", "🍀", "🌻"]

    var body: some View {
        VStack(spacing: 24) {
            switch s.phase {
            case .preparing: preparingUI
            case .active:    activeUI
            case .done:      doneUI
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .seniorScreen()
        .navigationTitle("腿脚操")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(s.phase == .active)
        .onAppear { s.start() }
        .onDisappear { s.cancel() }
        .onChange(of: s.phase) { _, newPhase in
            if newPhase == .done && !saved {
                saved = true
                store.addFall(reps: s.reps, level: levelString(s.level))
            }
        }
    }

    // B3 准备倒计时
    private var preparingUI: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("\(s.countdown)")
                .font(.system(size: 120, weight: .bold, design: .rounded))
                .foregroundStyle(LeLingColor.accent)
                .contentTransition(.numericText())
                .animation(.snappy, value: s.countdown)
            Text("我们准备好了…")
                .font(.senior(.title))
                .foregroundStyle(LeLingColor.primaryText)
            Label("先坐好，别急", systemImage: "speaker.wave.2.fill")
                .font(.senior(.body))
                .foregroundStyle(LeLingColor.accentDeep)
            Spacer()
        }
    }

    // B4 活动中（开花，无成绩）
    private var activeUI: some View {
        VStack(spacing: 20) {
            // 治愈花园：每完成一次坐站，多一朵
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(LeLingColor.accent.opacity(0.08))
                if s.reps == 0 {
                    Text("站起来一次，就开一朵花 🌱")
                        .font(.senior(.body))
                        .foregroundStyle(LeLingColor.secondaryText)
                } else {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 14) {
                        ForEach(0..<s.reps, id: \.self) { i in
                            Text(garden[i % garden.count])
                                .font(.system(size: 34))
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(20)
                    .animation(.spring(duration: 0.4), value: s.reps)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 300)

            Label("很好～再来一个", systemImage: "speaker.wave.2.fill")
                .font(.senior(.headline))
                .foregroundStyle(LeLingColor.good)

            Spacer()

            Button {
                s.stopEarly()
            } label: {
                Text("歇一下 / 停下来")
                    .font(.senior(.headline))
                    .foregroundStyle(LeLingColor.secondaryText)
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(LeLingColor.cardSurface, in: RoundedRectangle(cornerRadius: 18))
            }
        }
    }

    // B5 做完（暖话，零分级）
    private var doneUI: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("🌼")
                .font(.system(size: 90))
            Text("做完啦，辛苦您了～")
                .font(.senior(.title))
                .foregroundStyle(LeLingColor.primaryText)
            Text("今天腿脚挺利索的，\n歇会儿，喝口水 🍵")
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

            Button { dismiss() } label: {
                Text("回首页")
                    .font(.senior(.headline))
                    .foregroundStyle(LeLingColor.accentDeep)
                    .frame(maxWidth: .infinity, minHeight: 60)
            }
        }
    }
}

/// HealthLevel → 存储用字符串。
func levelString(_ level: HealthLevel) -> String {
    switch level {
    case .good:    return "good"
    case .caution: return "caution"
    case .risk:    return "risk"
    }
}

#Preview {
    NavigationStack { LegExerciseIntroView() }
        .environmentObject(LeLingStore())
}
