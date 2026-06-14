import SwiftUI

/// F1 · 🆘 紧急呼叫确认（红底，防误触）
struct SOSView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var sendLocation = true

    var body: some View {
        ZStack {
            LeLingColor.risk.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Label("紧急呼叫", systemImage: "phone.circle.fill")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("即将拨打电话给")
                    .font(.senior(.body))
                    .foregroundStyle(.white.opacity(0.9))

                VStack(spacing: 6) {
                    Text("女儿 王芳")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("138****5678")
                        .font(.senior(.headline))
                        .foregroundStyle(.white.opacity(0.9))
                }

                ZStack {
                    Circle().stroke(.white.opacity(0.4), lineWidth: 6).frame(width: 96, height: 96)
                    Text("3")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                Text("3 秒后自动拨打")
                    .font(.senior(.caption))
                    .foregroundStyle(.white.opacity(0.9))

                Spacer()

                HStack(spacing: 14) {
                    Button {
                        dismiss()
                    } label: {
                        Text("取消")
                            .font(.senior(.headline))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 64)
                            .background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 18))
                    }
                    Button { } label: {
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
    }
}

#Preview {
    SOSView()
}
