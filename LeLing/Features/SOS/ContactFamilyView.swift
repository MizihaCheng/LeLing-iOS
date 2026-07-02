import SwiftUI

// MARK: - E. 联系家人（原 SOS · 已降级，不吓人）
//
// 首页不再有大红🆘。这里平常心地「给谁打个电话」，
// 紧急求助藏在末尾（红色，但不在首页），防误触保留倒计时。

struct ContactFamilyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var showEmergency = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("想给谁打个电话？")
                        .font(.senior(.title))
                        .foregroundStyle(LeLingColor.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 4)

                    ForEach(SampleData.family) { c in
                        Button {
                            call(c.phone)
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: "phone.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(LeLingColor.accent)
                                    .frame(width: 40)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("\(c.relation) \(c.name)")
                                        .font(.senior(.headline))
                                        .foregroundStyle(LeLingColor.primaryText)
                                    Text(c.phone)
                                        .font(.senior(.caption))
                                        .foregroundStyle(LeLingColor.secondaryText)
                                }
                                Spacer()
                            }
                            .seniorCard()
                        }
                    }

                    // 紧急求助（藏这里，红）
                    Button {
                        showEmergency = true
                    } label: {
                        Label("我需要马上帮助", systemImage: "sos")
                            .font(.senior(.headline))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 64)
                            .background(LeLingColor.risk, in: RoundedRectangle(cornerRadius: 18))
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            .seniorScreen()
            .navigationTitle("联系家人")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").font(.headline)
                    }
                }
            }
            .fullScreenCover(isPresented: $showEmergency) {
                EmergencyConfirmView(contact: SampleData.family.first)
            }
        }
    }

    private func call(_ phone: String) {
        let digits = phone.filter { $0.isNumber }
        if let url = URL(string: "tel://\(digits)") { openURL(url) }
    }
}

/// E2 · 紧急确认（红底，防误触，倒计时自动拨）
struct EmergencyConfirmView: View {
    let contact: FamilyContact?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var countdown = 3
    @State private var sendLocation = true
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            LeLingColor.risk.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Label("需要帮助", systemImage: "phone.circle.fill")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("马上打给")
                    .font(.senior(.body))
                    .foregroundStyle(.white.opacity(0.9))

                VStack(spacing: 6) {
                    Text(contact.map { "\($0.relation) \($0.name)" } ?? "紧急联系人")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(contact?.phone ?? "")
                        .font(.senior(.headline))
                        .foregroundStyle(.white.opacity(0.9))
                }

                ZStack {
                    Circle().stroke(.white.opacity(0.4), lineWidth: 6).frame(width: 96, height: 96)
                    Text("\(countdown)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                        .animation(.snappy, value: countdown)
                }
                Text("\(countdown) 秒后自动拨打")
                    .font(.senior(.caption))
                    .foregroundStyle(.white.opacity(0.9))

                Spacer()

                HStack(spacing: 14) {
                    Button { cancel() } label: {
                        Text("取消")
                            .font(.senior(.headline))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 64)
                            .background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 18))
                    }
                    Button { dial() } label: {
                        Label("立即拨打", systemImage: "phone.fill")
                            .font(.senior(.headline))
                            .foregroundStyle(LeLingColor.risk)
                            .frame(maxWidth: .infinity, minHeight: 64)
                            .background(.white, in: RoundedRectangle(cornerRadius: 18))
                    }
                }

                Toggle(isOn: $sendLocation) {
                    Text("同时给 TA 发我的位置短信")
                        .font(.senior(.caption))
                        .foregroundStyle(.white)
                }
                .tint(.white)
                .padding(.bottom, 8)
            }
            .padding()
        }
        .onAppear { startCountdown() }
        .onDisappear { timer?.invalidate() }
    }

    private func startCountdown() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                countdown -= 1
                if countdown <= 0 { dial() }
            }
        }
    }

    private func cancel() {
        timer?.invalidate(); timer = nil
        dismiss()
    }

    private func dial() {
        timer?.invalidate(); timer = nil
        if let phone = contact?.phone {
            let digits = phone.filter { $0.isNumber }
            if let url = URL(string: "tel://\(digits)") { openURL(url) }
        }
        dismiss()
    }
}

#Preview {
    ContactFamilyView()
}
