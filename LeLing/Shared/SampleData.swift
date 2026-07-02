import SwiftUI

// MARK: - v2 共享数据与小组件
//
// 设计基调（见 设计-v2-轻松关怀版.md）：
//   · 老人端不显示任何临床数字/分级，只给积极定性反馈。
//   · 数字 / 🟢🟡🔴 分级只出现在「给子女的报告」里。
//   · HealthLevel 保留：仅供报告(PDF)与后台使用。

/// 健康等级：**只在给子女的报告里出现**，老人端界面不用。
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

/// 家人联系人（示例数据，后续接真实存储）。
struct FamilyContact: Identifiable {
    let id = UUID()
    let relation: String   // 女儿 / 儿子
    let name: String
    let phone: String
    var receivesReport: Bool
}

enum SampleData {
    static let name = "王建国"

    /// 首页 AI 一句暖心话（口语、鼓励，非健康告警）。
    static let greetingTip = "今天天气不错，记得多喝水，出门走走～"

    static let family: [FamilyContact] = [
        .init(relation: "女儿", name: "王芳", phone: "138****5678", receivesReport: true),
        .init(relation: "儿子", name: "王强", phone: "139****1234", receivesReport: false)
    ]

    /// 本月哪天活动过（true = 开花，false = 没动）——回顾页示例。
    static let monthActivity: [Bool] = [
        true, true, false, true, true, false, true,
        true, false, true, true, true, false, true,
        true, true, false, true, false, true, true,
        false, true, true, true, false, true, true,
        true, false
    ]

    /// 按当前时间给出问候语。
    static var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<11:  return "早上好"
        case 11..<13: return "中午好"
        case 13..<18: return "下午好"
        default:      return "晚上好"
        }
    }
}

// MARK: - 共享小组件

/// 摄像头取景占位框（模拟器无相机时用；真机接入后替换为实时画面）。
struct CameraPlaceholder: View {
    var caption: String = "摄像头画面"
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.black.opacity(0.82))
            VStack(spacing: 12) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.white.opacity(0.7))
                Text(caption)
                    .font(.senior(.body))
                    .foregroundStyle(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
    }
}

/// 小色点 + 文字的等级标签（**仅报告里用**）。
struct LevelTag: View {
    let level: HealthLevel
    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(level.color).frame(width: 12, height: 12)
            Text(level.label)
                .font(.senior(.caption))
                .foregroundStyle(level.color)
        }
    }
}
