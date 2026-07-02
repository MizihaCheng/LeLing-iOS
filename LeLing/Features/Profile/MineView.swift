import SwiftUI

/// A3 · 我的（设置 / 家人）
struct MineView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    NavigationLink { BasicInfoView() } label: {
                        HStack(spacing: 16) {
                            Text("😊").font(.system(size: 40)).frame(width: 52)
                            Text("\(SampleData.name)")
                                .font(.senior(.headline))
                                .foregroundStyle(LeLingColor.primaryText)
                            Spacer()
                            chevron
                        }
                        .seniorCard()
                    }

                    NavigationLink { FamilySettingsView() } label: {
                        MineRow(emoji: "👨‍👩‍👧", title: "家人", note: "联系人 · 谁收报告")
                    }
                    NavigationLink { FlowerPickerView() } label: {
                        MineRow(emoji: "🌸", title: "换一盆花", note: "挑一盆你喜欢的")
                    }
                    NavigationLink { RemindersView() } label: {
                        MineRow(emoji: "🔔", title: "温柔提醒", note: "活动 / 用药提醒")
                    }
                    NavigationLink { ReportShareView() } label: {
                        MineRow(emoji: "💌", title: "发给孩子（报告）", note: "微信 / 短信分享")
                    }
                    NavigationLink { AboutView() } label: {
                        MineRow(emoji: "🔒", title: "关于与隐私", note: "数据全存本机")
                    }
                }
                .padding()
            }
            .seniorScreen()
            .navigationTitle("我的")
        }
    }

    private var chevron: some View {
        Image(systemName: "chevron.right").font(.headline).foregroundStyle(LeLingColor.secondaryText)
    }
}

struct MineRow: View {
    let emoji: String
    let title: String
    let note: String

    var body: some View {
        HStack(spacing: 16) {
            Text(emoji).font(.system(size: 30)).frame(width: 40)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.senior(.body)).foregroundStyle(LeLingColor.primaryText)
                if !note.isEmpty {
                    Text(note).font(.senior(.caption)).foregroundStyle(LeLingColor.secondaryText)
                }
            }
            Spacer()
            Image(systemName: "chevron.right").font(.headline).foregroundStyle(LeLingColor.secondaryText)
        }
        .seniorCard()
    }
}

// MARK: - F1 · 家人（联系人 + 谁收报告 + 自动跌倒报警）
struct FamilySettingsView: View {
    @State private var autoFallAlert = true

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("这些人可以一键联系，\n也会收到您的健康小报告")
                    .font(.senior(.body))
                    .foregroundStyle(LeLingColor.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ForEach(SampleData.family) { c in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(c.relation) \(c.name)")
                                    .font(.senior(.body)).foregroundStyle(LeLingColor.primaryText)
                                Text(c.phone)
                                    .font(.senior(.caption)).foregroundStyle(LeLingColor.secondaryText)
                            }
                            Spacer()
                            Image(systemName: "pencil").font(.headline).foregroundStyle(LeLingColor.accent)
                        }
                        Label(c.receivesReport ? "接收健康报告" : "不接收报告",
                              systemImage: c.receivesReport ? "checkmark.circle.fill" : "circle")
                            .font(.senior(.caption))
                            .foregroundStyle(c.receivesReport ? LeLingColor.good : LeLingColor.secondaryText)
                    }
                    .seniorCard()
                }

                Button { } label: {
                    Label("添加家人", systemImage: "plus.circle.fill")
                }
                .buttonStyle(SeniorPrimaryButtonStyle())

                // 自动跌倒报警
                VStack(alignment: .leading, spacing: 10) {
                    Toggle(isOn: $autoFallAlert) {
                        Label("检测到跌倒，自动呼叫", systemImage: "figure.fall")
                            .font(.senior(.headline))
                            .foregroundStyle(LeLingColor.primaryText)
                    }
                    .tint(LeLingColor.risk)
                    Text("需手机带在身上才有效；感应到疑似摔倒会先弹倒计时，没取消再自动拨打。")
                        .font(.senior(.caption))
                        .foregroundStyle(LeLingColor.secondaryText)
                }
                .seniorCard()
            }
            .padding()
        }
        .seniorScreen()
        .navigationTitle("家人")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - F2 · 温柔提醒
struct RemindersView: View {
    @State private var activeOn = true
    @State private var medOn = true

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("🌿 活动提醒")
                        .font(.senior(.headline))
                        .foregroundStyle(LeLingColor.primaryText)
                    Toggle(isOn: $activeOn) {
                        Text("每天问候我一次").font(.senior(.body))
                    }.tint(LeLingColor.accent)
                    HStack {
                        Text("时间").font(.senior(.body)).foregroundStyle(LeLingColor.secondaryText)
                        Spacer()
                        Text("上午 9:00").font(.senior(.body)).foregroundStyle(LeLingColor.primaryText)
                    }
                }
                .seniorCard()

                VStack(alignment: .leading, spacing: 12) {
                    Text("💊 用药提醒")
                        .font(.senior(.headline))
                        .foregroundStyle(LeLingColor.primaryText)
                    Toggle(isOn: $medOn) {
                        Text("降压药 · 上午 8:00").font(.senior(.body))
                    }.tint(LeLingColor.accent)
                    Label("添加用药提醒", systemImage: "plus.circle")
                        .font(.senior(.body))
                        .foregroundStyle(LeLingColor.accent)
                }
                .seniorCard()
            }
            .padding()
        }
        .seniorScreen()
        .navigationTitle("温柔提醒")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - F3 · 基本信息
struct BasicInfoView: View {
    @State private var name = SampleData.name
    @State private var age = "78"
    @State private var sex = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                field("称呼") { TextField("称呼", text: $name).font(.senior(.body)) }
                VStack(alignment: .leading, spacing: 8) {
                    Text("性别").font(.senior(.caption)).foregroundStyle(LeLingColor.secondaryText)
                    Picker("性别", selection: $sex) {
                        Text("男").tag(0); Text("女").tag(1)
                    }.pickerStyle(.segmented)
                }
                field("年龄（岁）") { TextField("年龄", text: $age).font(.senior(.body)) }

                Text("这些只用来把报告算得更准，\n只存在您手机里，不会上传。")
                    .font(.senior(.caption))
                    .foregroundStyle(LeLingColor.secondaryText)

                Button { } label: { Text("保存") }
                    .buttonStyle(SeniorPrimaryButtonStyle())
            }
            .padding()
        }
        .seniorScreen()
        .navigationTitle("基本信息")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func field<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.senior(.caption)).foregroundStyle(LeLingColor.secondaryText)
            content()
                .padding(14)
                .background(LeLingColor.cardSurface, in: RoundedRectangle(cornerRadius: 14))
        }
    }
}

// MARK: - F4 · 关于与隐私
struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("乐龄守护")
                    .font(.senior(.title))
                    .foregroundStyle(LeLingColor.primaryText)

                Label("您的所有健康数据只存在这部手机里，不会上传网络。", systemImage: "lock.fill")
                    .font(.senior(.body))
                    .foregroundStyle(LeLingColor.accentDeep)

                Text("本应用用手机摄像头帮您轻松活动、记录状态，结果仅供参考。")
                    .font(.senior(.body))
                    .foregroundStyle(LeLingColor.primaryText)

                Text("身体不舒服，记得找医生 🩺")
                    .font(.senior(.body))
                    .foregroundStyle(LeLingColor.risk)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .seniorScreen()
        .navigationTitle("关于与隐私")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MineView()
        .environmentObject(LeLingStore())
}
