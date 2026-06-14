import SwiftUI

// MARK: - C. 心率 / 呼吸自查流程（UI 静态版，不接 rPPG）

/// C1 · 说明页
struct VitalsIntroView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                CameraPlaceholder(caption: "脸正对前置摄像头")
                    .frame(height: 180)

                VStack(alignment: .leading, spacing: 14) {
                    Text("怎么做")
                        .font(.senior(.headline))
                        .foregroundStyle(LeLingColor.primaryText)
                    stepRow("①", "坐稳，光线充足")
                    stepRow("②", "脸正对屏幕上方摄像头")
                    stepRow("③", "保持不动约 30 秒")
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Label("测量时请勿说话", systemImage: "speaker.wave.2.fill")
                    .font(.senior(.body))
                    .foregroundStyle(LeLingColor.accentDeep)

                NavigationLink {
                    VitalsMeasuringView()
                } label: {
                    Text("开始测量")
                }
                .buttonStyle(SeniorPrimaryButtonStyle())

                Text("〔切换〕也可改用手指贴后置摄像头")
                    .font(.senior(.caption))
                    .foregroundStyle(LeLingColor.secondaryText)
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

/// C2 · 测量中（静态示例：进度环 + 心跳）
struct VitalsMeasuringView: View {
    var body: some View {
        VStack(spacing: 28) {
            CameraPlaceholder(caption: "脸部取景")
                .frame(width: 160, height: 160)
                .clipShape(Circle())
                .padding(.top, 12)

            ZStack {
                Circle()
                    .stroke(LeLingColor.divider, lineWidth: 16)
                Circle()
                    .trim(from: 0, to: 0.68)
                    .stroke(LeLingColor.accent, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("68%")
                    .font(.senior(.title))
                    .foregroundStyle(LeLingColor.primaryText)
            }
            .frame(width: 180, height: 180)

            Text("❤️ 测量中…")
                .font(.senior(.headline))
                .foregroundStyle(LeLingColor.primaryText)

            Label("“保持不动，马上就好”", systemImage: "speaker.wave.2.fill")
                .font(.senior(.body))
                .foregroundStyle(LeLingColor.accentDeep)

            Spacer()

            NavigationLink {
                VitalsResultView()
            } label: {
                Text("查看结果（示例）")
            }
            .buttonStyle(SeniorPrimaryButtonStyle())
        }
        .padding()
        .seniorScreen()
        .navigationTitle("测量中")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// C3 · 结果页
struct VitalsResultView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack(spacing: 14) {
                    vitalResult(icon: "❤️", name: "心率", value: "72", unit: "次/分", note: "比上次 ↓3", level: .good)
                    vitalResult(icon: "🫁", name: "呼吸", value: "16", unit: "次/分", note: "正常", level: .good)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("解读")
                        .font(.senior(.headline))
                        .foregroundStyle(LeLingColor.primaryText)
                    Text("心率与呼吸都在正常范围。")
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
        .navigationTitle("自查结果")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func vitalResult(icon: String, name: String, value: String, unit: String, note: String, level: HealthLevel) -> some View {
        VStack(spacing: 8) {
            Text("\(icon) \(name)")
                .font(.senior(.headline))
                .foregroundStyle(LeLingColor.primaryText)
            Text(value)
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(LeLingColor.primaryText)
            HStack(spacing: 5) {
                Text(unit)
                    .font(.senior(.caption))
                    .foregroundStyle(LeLingColor.secondaryText)
                Circle().fill(level.color).frame(width: 12, height: 12)
            }
            Text(note)
                .font(.senior(.caption))
                .foregroundStyle(LeLingColor.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(LeLingColor.cardSurface, in: RoundedRectangle(cornerRadius: 22))
    }
}

#Preview {
    NavigationStack { VitalsIntroView() }
}
