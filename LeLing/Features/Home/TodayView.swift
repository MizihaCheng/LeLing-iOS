import SwiftUI

/// A1 · 今天（首页）—— 养花「状态镜子」主页
/// 一打开：一盆花当正中主角 + 一句暖话 + 下方「看看今天怎么样」。
/// （天气/状态映射后续再接，见 设计-养花状态镜子.md）
struct TodayView: View {
    @State private var showContactFamily = false
    @AppStorage("selectedFlower") private var selectedFlower = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    // 问候（放小，让位给花）
                    Text("\(SampleData.name)，\(SampleData.greeting) ☀️")
                        .font(.senior(.headline))
                        .foregroundStyle(LeLingColor.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // 那盆花：主角
                    PottedFlowerView(flowerIndex: selectedFlower)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 4)

                    // 一句暖话（永远往好里说）
                    Text("今天花儿精神着呢～")
                        .font(.senior(.title))
                        .foregroundStyle(LeLingColor.primaryText)
                        .multilineTextAlignment(.center)

                    Text(SampleData.greetingTip)
                        .font(.senior(.body))
                        .foregroundStyle(LeLingColor.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)

                    // 一键：全部做一遍
                    NavigationLink {
                        LegExerciseIntroView()   // TODO: 串成「腿脚操→静一静」连做一遍
                    } label: {
                        Label("看看今天怎么样", systemImage: "sun.max.fill")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 74)
                            .background(LeLingColor.accent, in: RoundedRectangle(cornerRadius: 22))
                    }
                    .padding(.top, 4)

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

#Preview {
    TodayView()
        .environmentObject(LeLingStore())
}
