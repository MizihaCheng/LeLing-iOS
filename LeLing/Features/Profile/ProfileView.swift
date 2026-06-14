import SwiftUI

/// A4 · 我的
struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    NavigationLink {
                        BasicInfoView()
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(LeLingColor.accent)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(SampleData.name)")
                                    .font(.senior(.headline))
                                    .foregroundStyle(LeLingColor.primaryText)
                                Text("78 岁 · 男")
                                    .font(.senior(.caption))
                                    .foregroundStyle(LeLingColor.secondaryText)
                            }
                            Spacer()
                            chevron
                        }
                        .seniorCard()
                    }

                    NavigationLink { EmergencyContactsView() } label: {
                        ProfileRow(icon: "phone.fill", title: "紧急联系人", note: "女儿 王芳")
                    }
                    NavigationLink { RemindersView() } label: {
                        ProfileRow(icon: "bell.fill", title: "提醒设置", note: "测量 / 用药提醒")
                    }
                    NavigationLink { ReportView() } label: {
                        ProfileRow(icon: "square.and.arrow.up", title: "导出 / 发给子女", note: "PDF / 微信 / 短信")
                    }
                    NavigationLink { AboutView() } label: {
                        ProfileRow(icon: "info.circle.fill", title: "关于与免责声明", note: "")
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

struct ProfileRow: View {
    let icon: String
    let title: String
    let note: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 26))
                .foregroundStyle(LeLingColor.accent)
                .frame(width: 36)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.senior(.body))
                    .foregroundStyle(LeLingColor.primaryText)
                if !note.isEmpty {
                    Text(note)
                        .font(.senior(.caption))
                        .foregroundStyle(LeLingColor.secondaryText)
                }
            }
            Spacer()
            Image(systemName: "chevron.right").font(.headline).foregroundStyle(LeLingColor.secondaryText)
        }
        .seniorCard()
    }
}

// MARK: - G1 · 紧急联系人
struct EmergencyContactsView: View {
    @State private var autoFallAlert = true

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 自动跌倒报警开关
                VStack(alignment: .leading, spacing: 10) {
                    Toggle(isOn: $autoFallAlert) {
                        Label("检测到跌倒，自动呼叫", systemImage: "figure.fall")
                            .font(.senior(.headline))
                            .foregroundStyle(LeLingColor.primaryText)
                    }
                    .tint(LeLingColor.risk)
                    Text("手机带在身上时，若感应到疑似摔倒，会先弹出倒计时，没取消就自动拨打紧急联系人。")
                        .font(.senior(.caption))
                        .foregroundStyle(LeLingColor.secondaryText)
                }
                .seniorCard()

                Text("SOS 会按顺序拨打这些电话")
                    .font(.senior(.body))
                    .foregroundStyle(LeLingColor.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)

                contactRow("女儿 王芳", "138****5678")
                contactRow("儿子 王强", "139****1234")

                Button { } label: {
                    Label("添加联系人", systemImage: "plus.circle.fill")
                }
                .buttonStyle(SeniorPrimaryButtonStyle())

                Text("可从通讯录选择，或手动输入。")
                    .font(.senior(.caption))
                    .foregroundStyle(LeLingColor.secondaryText)
            }
            .padding()
        }
        .seniorScreen()
        .navigationTitle("紧急联系人")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func contactRow(_ name: String, _ phone: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(name).font(.senior(.body)).foregroundStyle(LeLingColor.primaryText)
                Text(phone).font(.senior(.caption)).foregroundStyle(LeLingColor.secondaryText)
            }
            Spacer()
            Image(systemName: "pencil").font(.headline).foregroundStyle(LeLingColor.accent)
        }
        .seniorCard()
    }
}

// MARK: - G2 · 提醒设置
struct RemindersView: View {
    @State private var measureOn = true
    @State private var medOn = true

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("💗 测量提醒")
                        .font(.senior(.headline))
                        .foregroundStyle(LeLingColor.primaryText)
                    Toggle(isOn: $measureOn) {
                        Text("每天提醒我自查").font(.senior(.body))
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
        .navigationTitle("提醒设置")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - G3 · 基本信息
struct BasicInfoView: View {
    @State private var name = SampleData.name
    @State private var age = "78"
    @State private var sex = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                field("姓名") { TextField("姓名", text: $name).font(.senior(.body)) }
                VStack(alignment: .leading, spacing: 8) {
                    Text("性别").font(.senior(.caption)).foregroundStyle(LeLingColor.secondaryText)
                    Picker("性别", selection: $sex) {
                        Text("男").tag(0); Text("女").tag(1)
                    }.pickerStyle(.segmented)
                }
                field("年龄（岁）") { TextField("年龄", text: $age).font(.senior(.body)) }

                Text("用于评估的健康基准，只存在本机，不会上传。")
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

// MARK: - G4 · 关于与免责声明
struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("乐龄守护  v1.0")
                    .font(.senior(.title))
                    .foregroundStyle(LeLingColor.primaryText)

                Text("本应用通过手机摄像头提供健康自查与趋势提示，结果仅供参考。")
                    .font(.senior(.body))
                    .foregroundStyle(LeLingColor.primaryText)

                Text("⚠️ 不构成医疗诊断，不能替代医生与专业设备。如有不适请及时就医。")
                    .font(.senior(.body))
                    .foregroundStyle(LeLingColor.risk)

                Text("所有健康数据仅存于本机，不会上传云端。")
                    .font(.senior(.body))
                    .foregroundStyle(LeLingColor.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .seniorScreen()
        .navigationTitle("关于与免责声明")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProfileView()
}
