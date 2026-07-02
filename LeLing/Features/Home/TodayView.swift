import SwiftUI

/// A1 · 今天（首页）
/// 基调：温暖、零数字、零红色、零倒计时。像陪伴，不像体检。
struct TodayView: View {
    @State private var showContactFamily = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    // 问候 + 一句暖心话
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(SampleData.name)，\(SampleData.greeting) ☀️")
                            .font(.senior(.title))
                            .foregroundStyle(LeLingColor.primaryText)
                        Text(SampleData.greetingTip)
                            .font(.senior(.body))
                            .foregroundStyle(LeLingColor.secondaryText)
                    }

                    // 今天想做点什么
                    Text("今天想做点什么？")
                        .font(.senior(.headline))
                        .foregroundStyle(LeLingColor.primaryText)
                        .padding(.top, 4)

                    NavigationLink {
                        LegExerciseIntroView()
                    } label: {
                        ActivityCard(
                            emoji: "🪑",
                            title: "陪您活动活动腿脚",
                            subtitle: "坐下起立，慢慢来，不着急"
                        )
                    }

                    NavigationLink {
                        CalmIntroView()
                    } label: {
                        ActivityCard(
                            emoji: "🌿",
                            title: "静一静，听听心跳",
                            subtitle: "跟着呼吸放松一下"
                        )
                    }

                    NavigationLink {
                        LegExerciseIntroView()   // TODO: 串成「腿脚操→静一静」连做
                    } label: {
                        Text("✨ 一起做一遍（约 2 分钟）")
                            .font(.senior(.headline))
                            .foregroundStyle(LeLingColor.accentDeep)
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .background(LeLingColor.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 18))
                    }

                    // 上次（定性，不给数字）
                    VStack(alignment: .leading, spacing: 6) {
                        Text("上次 · 昨天做过了 👍")
                            .font(.senior(.body))
                            .foregroundStyle(LeLingColor.primaryText)
                        Text("「那天状态挺好的」")
                            .font(.senior(.caption))
                            .foregroundStyle(LeLingColor.secondaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .seniorCard()

                    // 用药提醒（柔性）
                    HStack {
                        Text("💊 温柔提醒：该吃降压药啦")
                            .font(.senior(.body))
                            .foregroundStyle(LeLingColor.primaryText)
                        Spacer()
                        Text("上午 8:00")
                            .font(.senior(.caption))
                            .foregroundStyle(LeLingColor.secondaryText)
                    }
                    .seniorCard()
                }
                .padding()
            }
            .seniorScreen()
            .navigationTitle("乐龄守护")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showContactFamily = true
                    } label: {
                        Label("家人", systemImage: "phone.fill")
                            .font(.senior(.caption))
                            .foregroundStyle(LeLingColor.accent)
                    }
                }
            }
            .sheet(isPresented: $showContactFamily) {
                ContactFamilyView()
            }
        }
    }
}

/// 「今天」页的活动大入口卡。
struct ActivityCard: View {
    let emoji: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 18) {
            Text(emoji)
                .font(.system(size: 44))
                .frame(width: 60)
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.senior(.headline))
                    .foregroundStyle(LeLingColor.primaryText)
                Text(subtitle)
                    .font(.senior(.caption))
                    .foregroundStyle(LeLingColor.secondaryText)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.headline)
                .foregroundStyle(LeLingColor.secondaryText)
        }
        .seniorCard()
    }
}

#Preview {
    TodayView()
        .environmentObject(LeLingStore())
}
