import SwiftUI

// MARK: - 仅用于 UI 静态展示的示例数据与小组件（不含任何真实功能）

/// 健康等级：全 app 统一的 🟢🟡🔴 表意。
enum HealthLevel {
    case good, caution, risk

    var color: Color {
        switch self {
        case .good:    return LeLingColor.good
        case .caution: return LeLingColor.caution
        case .risk:    return LeLingColor.risk
        }
    }

    var label: String {
        switch self {
        case .good:    return "良好"
        case .caution: return "注意"
        case .risk:    return "偏高"
        }
    }
}

/// 趋势图的一个数据点。
struct DayPoint: Identifiable {
    let id = UUID()
    let day: String
    let value: Double
}

enum SampleData {
    static let name = "王建国"
    static let greetingTip = "今天天气不错，记得多喝水。"

    static let heartTrend: [DayPoint] = [
        .init(day: "一", value: 75), .init(day: "二", value: 73),
        .init(day: "三", value: 78), .init(day: "四", value: 72),
        .init(day: "五", value: 71), .init(day: "六", value: 74),
        .init(day: "日", value: 72)
    ]

    static let weekColors: [HealthLevel?] = [.good, .good, .caution, .good, .good, nil, .good]
}

// MARK: - 共享小组件

/// 小色点 + 文字的等级标签。
struct LevelTag: View {
    let level: HealthLevel
    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(level.color).frame(width: 14, height: 14)
            Text(level.label)
                .font(.senior(.caption))
                .foregroundStyle(level.color)
        }
    }
}

/// 首页用的生命体征小卡（图标 + 大数字 + 单位 + 等级点）。
struct VitalMiniCard: View {
    let icon: String
    let value: String
    let unit: String
    let level: HealthLevel

    var body: some View {
        VStack(spacing: 6) {
            Text(icon).font(.system(size: 28))
            Text(value)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(LeLingColor.primaryText)
            HStack(spacing: 5) {
                Text(unit)
                    .font(.senior(.caption))
                    .foregroundStyle(LeLingColor.secondaryText)
                Circle().fill(level.color).frame(width: 12, height: 12)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(LeLingColor.cardSurface, in: RoundedRectangle(cornerRadius: 20))
    }
}

/// 结果页用的大数字方框。
struct StatBox: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.senior(.caption))
                .foregroundStyle(LeLingColor.secondaryText)
            Text(value)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(LeLingColor.primaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .background(LeLingColor.cardSurface, in: RoundedRectangle(cornerRadius: 20))
    }
}

/// 摄像头取景占位框（UI 阶段不接真实相机）。
struct CameraPlaceholder: View {
    var caption: String = "摄像头画面"
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.black.opacity(0.85))
            VStack(spacing: 12) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.white.opacity(0.7))
                Text(caption)
                    .font(.senior(.body))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }
}
