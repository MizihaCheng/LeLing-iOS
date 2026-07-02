import SwiftUI

// MARK: - 主页那盆花（状态镜子的载体）
//
// 现阶段：只负责「把选中的花（＋盆）显示出来、摇曳」。
// 状态映射（精神/歇息）初赛先放一放，见 设计-养花状态镜子.md §5.1。
//
// 花与盆是两个独立 Lottie，用 ZStack 拼（方案 C）。
// ⚠️ 对齐要在 Mac 模拟器里眼调——下面 TUNE 区的常量就是给你调的。

/// 三种花的资源与名字（同作者，弄好一个其余照搬）。
enum FlowerCatalog {
    static let assets = ["flower1", "flower2", "flower3"]
    static let names  = ["摇曳的花", "小树花", "绽放的花"]
    static var count: Int { assets.count }

    static func assetName(_ index: Int) -> String {
        let i = min(max(index, 0), assets.count - 1)
        return assets[i]
    }
}

struct PottedFlowerView: View {
    var flowerIndex: Int
    /// 是否叠一个单独的花盆。若你的花素材自带盆、或 pot.json 里本身已有植物导致“重影”，
    /// 就把它设为 false，只显示花。
    var showPot: Bool = true

    // ————————— TUNE：到 Mac 上眼调这几个，让花“坐进”盆里 —————————
    private let boxSize    = CGSize(width: 300, height: 320) // 整体画布
    private let potSize    : CGFloat = 190                    // 花盆大小
    private let flowerSize : CGFloat = 260                    // 花的显示大小
    private let flowerYOffset: CGFloat = -70                  // 花上移量（负=往上，坐进盆口）
    // ————————————————————————————————————————————————————

    var body: some View {
        ZStack(alignment: .bottom) {
            if showPot {
                LottiePlayer(name: "pot")
                    .frame(width: potSize, height: potSize)
            }
            LottiePlayer(name: FlowerCatalog.assetName(flowerIndex))
                .frame(width: flowerSize, height: flowerSize)
                .offset(y: flowerYOffset)
        }
        .frame(width: boxSize.width, height: boxSize.height)
    }
}

// MARK: - 换一盆花（设置里进）

struct FlowerPickerView: View {
    @AppStorage("selectedFlower") private var selectedFlower = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("挑一盆你喜欢的花")
                    .font(.senior(.headline))
                    .foregroundStyle(LeLingColor.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ForEach(0..<FlowerCatalog.count, id: \.self) { i in
                    Button {
                        selectedFlower = i
                    } label: {
                        HStack(spacing: 16) {
                            LottiePlayer(name: FlowerCatalog.assets[i])
                                .frame(width: 84, height: 84)
                            Text(FlowerCatalog.names[i])
                                .font(.senior(.body))
                                .foregroundStyle(LeLingColor.primaryText)
                            Spacer()
                            Image(systemName: selectedFlower == i ? "checkmark.circle.fill" : "circle")
                                .font(.title2)
                                .foregroundStyle(selectedFlower == i ? LeLingColor.accent : LeLingColor.secondaryText)
                        }
                        .seniorCard()
                    }
                }
            }
            .padding()
        }
        .seniorScreen()
        .navigationTitle("换一盆花")
        .navigationBarTitleDisplayMode(.inline)
    }
}
