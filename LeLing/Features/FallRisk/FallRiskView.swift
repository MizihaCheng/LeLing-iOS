import SwiftUI

// MARK: - B. 跌倒风险评估流程（UI 静态版，不接 Vision）

/// B1 · 说明页
struct FallRiskIntroView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                CameraPlaceholder(caption: "手机靠墙立稳 · 人站远露全身")
                    .frame(height: 180)

                VStack(alignment: .leading, spacing: 14) {
                    Text("怎么做")
                        .font(.senior(.headline))
                        .foregroundStyle(LeLingColor.primaryText)
                    stepRow("①", "把手机靠墙立稳")
                    stepRow("②", "后退到能看到全身")
                    stepRow("③", "听提示，反复「坐下—起立」")
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Label("全程会有语音提示", systemImage: "speaker.wave.2.fill")
                    .font(.senior(.body))
                    .foregroundStyle(LeLingColor.accentDeep)

                NavigationLink {
                    FallRiskSessionView()
                } label: {
                    Text("我准备好了，开始")
                }
                .buttonStyle(SeniorPrimaryButtonStyle())

                Text("整个过程约 30 秒")
                    .font(.senior(.caption))
                    .foregroundStyle(LeLingColor.secondaryText)
            }
            .padding()
        }
        .seniorScreen()
        .navigationTitle("跌倒风险评估")
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

/// B4 · 测试中（静态示例：取景占位 + 大数字 + 进度）
struct FallRiskSessionView: View {
    var body: some View {
        VStack(spacing: 22) {
            CameraPlaceholder(caption: "摄像头画面 · 骨架叠加")
                .frame(maxWidth: .infinity)
                .frame(height: 240)

            HStack(spacing: 14) {
                StatBox(title: "已完成", value: "7 次")
                StatBox(title: "剩余时间", value: "18 秒")
            }

            ProgressView(value: 0.4)
                .tint(LeLingColor.accent)
                .scaleEffect(x: 1, y: 2.2, anchor: .center)
                .padding(.horizontal, 4)

            Label("“很好，继续，第 8 次”", systemImage: "speaker.wave.2.fill")
                .font(.senior(.body))
                .foregroundStyle(LeLingColor.accentDeep)

            Spacer()

            NavigationLink {
                FallRiskResultView()
            } label: {
                Text("查看结果（示例）")
            }
            .buttonStyle(SeniorPrimaryButtonStyle())
        }
        .padding()
        .seniorScreen()
        .navigationTitle("测试中")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// B5 · 结果页
struct FallRiskResultView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Circle()
                    .fill(HealthLevel.good.color)
                    .frame(width: 88, height: 88)
                    .overlay(Image(systemName: "checkmark").font(.system(size: 40, weight: .bold)).foregroundStyle(.white))
                    .padding(.top, 8)

                Text("风险：良好")
                    .font(.senior(.title))
                    .foregroundStyle(LeLingColor.primaryText)

                HStack(spacing: 14) {
                    StatBox(title: "坐站次数", value: "12 次")
                    StatBox(title: "平均用时", value: "2.4 秒")
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("解读")
                        .font(.senior(.headline))
                        .foregroundStyle(LeLingColor.primaryText)
                    Text("您 30 秒完成 12 次，下肢力量良好，跌倒风险较低，继续保持～")
                        .font(.senior(.body))
                        .foregroundStyle(LeLingColor.secondaryText)
                }
                .seniorCard()

                HStack(spacing: 14) {
                    Button { } label: {
                        Label("保存", systemImage: "square.and.arrow.down").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SeniorPrimaryButtonStyle())
                    Button { } label: {
                        Label("发子女", systemImage: "square.and.arrow.up").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SeniorPrimaryButtonStyle())
                }
            }
            .padding()
        }
        .seniorScreen()
        .navigationTitle("评估结果")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { FallRiskIntroView() }
}
