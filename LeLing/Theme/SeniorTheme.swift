import SwiftUI

// MARK: - 适老主题：高对比配色 + 超大字号 + 大按钮
//
// 设计原则（适老化 / 无障碍）：
//   1. 字大        —— 正文 ≥ 20pt，关键数字超大；并支持系统「动态字体」继续放大。
//   2. 对比强      —— 文字与背景对比度高，弱视也看得清。
//   3. 触控目标大  —— 按钮高度 ≥ 60pt，老人手指 / 手抖也好点。
//   4. 颜色表意     —— 绿=良好、橙=注意、红=偏高/风险，全 app 统一。
//
// 用法：在视图上调用 `.seniorScreen()` 铺背景；用 `LeLingColor` 取色；
//      文字用 `.font(.senior(.body))`；主行动按钮用 `SeniorPrimaryButtonStyle`。

// MARK: 配色

enum LeLingColor {
    /// 按浅色 / 深色十六进制生成动态颜色（跟随系统深色模式）
    private static func dynamic(light: UInt, dark: UInt) -> Color {
        Color(uiColor: UIColor { trait in
            let hex = trait.userInterfaceStyle == .dark ? dark : light
            return UIColor(
                red: CGFloat((hex >> 16) & 0xff) / 255,
                green: CGFloat((hex >> 8) & 0xff) / 255,
                blue: CGFloat(hex & 0xff) / 255,
                alpha: 1
            )
        })
    }

    // 背景 / 卡片
    static let background   = dynamic(light: 0xF4F7F6, dark: 0x121615)
    static let cardSurface  = dynamic(light: 0xFFFFFF, dark: 0x1E2422)

    // 文字（高对比）
    static let primaryText  = dynamic(light: 0x16201D, dark: 0xF1F5F3)
    static let secondaryText = dynamic(light: 0x4C5A55, dark: 0xB8C2BE)

    // 品牌主色（沉稳青绿 = 健康 / 信任）
    static let accent       = dynamic(light: 0x1C6F8A, dark: 0x38A3C2)
    static let accentDeep    = dynamic(light: 0x12536A, dark: 0x57B7D2)

    // 语义色：评估结果 / 趋势统一用这三色
    static let good         = dynamic(light: 0x2E8B57, dark: 0x53C285)   // 良好
    static let caution      = dynamic(light: 0xCC7A1F, dark: 0xE69A4A)   // 注意
    static let risk         = dynamic(light: 0xC0392B, dark: 0xE2685A)   // 偏高 / 风险

    static let divider      = dynamic(light: 0xE3EAE7, dark: 0x2C3431)
}

// MARK: 字号（语义化，全部偏大，并支持动态字体继续放大）

extension Font {
    enum SeniorTextStyle {
        case hero      // 超大数字（如心率 72）
        case title     // 页面 / 卡片标题
        case headline  // 小标题
        case body      // 正文
        case caption   // 辅助说明 / 免责声明
    }

    static func senior(_ style: SeniorTextStyle) -> Font {
        switch style {
        case .hero:     return .system(size: 64, weight: .bold,     design: .rounded)
        case .title:    return .system(size: 30, weight: .bold,     design: .rounded)
        case .headline: return .system(size: 24, weight: .semibold, design: .rounded)
        case .body:     return .system(size: 21, weight: .regular,  design: .rounded)
        case .caption:  return .system(size: 17, weight: .regular,  design: .rounded)
        }
    }
}

// MARK: 大按钮样式

/// 主行动按钮：满宽、高 ≥ 64pt、强对比。用于「开始自查」「开始评估」这类主操作。
struct SeniorPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.senior(.headline))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 64)
            .background(
                LeLingColor.accent.opacity(configuration.isPressed ? 0.85 : 1),
                in: RoundedRectangle(cornerRadius: 18)
            )
            .contentShape(RoundedRectangle(cornerRadius: 18))
    }
}

// MARK: 视图修饰

extension View {
    /// 统一页面外观：铺适老背景色。
    func seniorScreen() -> some View {
        self.background(LeLingColor.background.ignoresSafeArea())
    }

    /// 白色圆角大卡片。
    func seniorCard(padding: CGFloat = 22) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(LeLingColor.cardSurface, in: RoundedRectangle(cornerRadius: 24))
    }
}
