# 实现规格 · 腿脚操（Vision 坐站检测）

> 面向"到了 Mac / 真机直接照着写"的技术规格。配合 [设计-v2-轻松关怀版.md](设计-v2-轻松关怀版.md) §5.1、[线框图-v2-轻松关怀版.md](线框图-v2-轻松关怀版.md) B 节看。
> **本文仍属规划**：给算法、状态机、接口、验证清单，不含成品代码。真机以 **iPhone 13 mini（A15，支持 Vision）** 为准。
> 目标读者 = 之后埋头写代码的自己/组员。

---

## 0. 一句话

摄像头看老人在椅子上**反复起立/坐下**，用 Vision 人体姿态点判"坐↔站"、计次数与每次耗时 → 后台算成 CST 指标+风险分级（**只进 PDF，不给老人看**），老人端只看到治愈动效与鼓励语。

---

## 1. 临床内核（要算什么）

- **依据**：30 秒椅子坐站测试（30-Second Chair Stand Test, CST）——30 秒内完成的完整"坐→站→坐"次数；或五次坐站计时（FTSST）。老年医学标准量表，衡量下肢力量与跌倒风险。
- **我们采集**：
  - `reps`：30 秒内完整坐站次数。
  - `perRepSeconds[]`：每次起立→坐下耗时。
  - `avgSeconds`：平均每次耗时。
  - `stability`：起立过程重心/关节抖动程度（可选，做趋势用）。
- **分级（good/caution/risk）**：按 CST 常模，**按年龄/性别分档**（老人在 [基本信息] 里填了）。MVP 可先用粗阈值，后续接常模表。
  - 例（占位，需查常模替换）：60–69 岁男性 ≥14 次良好、12–13 注意、<12 偏高。**实现时务必用查得的常模，别用这行占位数**。

---

## 2. 技术选型

- **框架**：Vision `VNDetectHumanBodyPoseRequest`（iOS 14+，本地、免费、不联网）。
- **管线**：`AVCaptureSession` 逐帧 → `CVPixelBuffer` → `VNImageRequestHandler` 跑姿态请求 → 取 `VNHumanBodyPoseObservation` 关节点。
- **复用现有模式**：相机采集/线程模型**照搬 [PPGCameraController](LeLing/Features/Vitals/PPGMeasurer.swift) 的写法**——`nonisolated` + `@unchecked Sendable` 控制器跑自己的 `DispatchQueue`，主线程用 `Timer` 轮询状态，避免跨 actor 闭包（这套已在 PPG 里验证过思路，最省踩并发坑）。
- **摄像头**：**前摄**（老人要能看到屏幕上的引导/动效），`.builtInWideAngleCamera` position `.front`。⚠️与 PPG 的后摄不同。

---

## 3. 用哪些关节点

`VNHumanBodyPoseObservation.JointName` 里取：

- 髋：`.leftHip` `.rightHip`（**坐站主信号**——髋部垂直高度变化最明显）
- 膝：`.leftKnee` `.rightKnee`
- 踝：`.leftAnkle` `.rightAnkle`
- 肩：`.leftShoulder` `.rightShoulder`（辅助算躯干高度/稳定度）
- 根：`.root`（髋中点，可直接用）

**置信度过滤**：每个点带 `confidence`，只用 `> 0.3`（阈值待真机调）的点；关键点连续多帧低置信 → 判"看不清"，提示老人调整（不报错、不中断计数逻辑，只暂停判定）。

坐标系：Vision 返回**归一化坐标 [0,1]，原点左下，y 向上**。别和 UIKit 的 y 向下搞混。

---

## 4. 坐↔站判定信号（核心）

单一信号都不稳，**组合两路互相印证**：

1. **髋部垂直高度 `hipY`**（主）：站立时 `hipY` 高、坐下时低。因人/距离/机位而异 → **不能用绝对阈值**，要在"取景对位阶段"先坐好，采一段基线定"坐着的 hipY 区间"，再动态判"明显高于基线 = 站起"。
2. **膝关节角度 `kneeAngle`**（辅）：由 髋-膝-踝 三点算夹角。坐≈90°弯曲，站≈170°接近伸直。角度对机位没那么敏感，适合和 hipY 交叉验证。

> 归一化：站/坐两态各自的 hipY、kneeAngle 先在校准段取"坐态中心"和预估"站态中心"，用**相对位移+滞回**判定，别用死阈值。

**滞回（防抖，重要）**：坐↔站切换用双阈值（Schmitt trigger）——从坐到站要越过 `highThr`，从站回坐要跌破 `lowThr`，中间留缓冲带，防止在临界点疯狂抖动误计数。

---

## 5. 状态机

```
        ┌────────────────────────────────────────────┐
        │                                            │
   [SITTING] ──hipY↑越过highThr──▶ [RISING] ──站稳──▶ [STANDING]
        ▲                                                │
        │                                                │
   [LOWERING] ◀──hipY↓跌破lowThr──────────────────────────┘
        │
        └──坐稳(回到坐态基线)──▶ 计一次 rep++, 记录本次耗时──▶ [SITTING]
```

- **一次 rep 的定义**：`SITTING → RISING → STANDING → LOWERING → SITTING` 走完整一圈才 `reps++`（避免半站半坐乱计）。
- **计时**：记 `RISING` 起点到回到 `SITTING` 的时间 = 本次 `perRepSeconds`。
- **稳定度**：`RISING/STANDING` 阶段采关节点抖动方差 → `stability`（可选，v2.1 再做）。
- **总时长**：`STANDING` 首次达成起算 30 秒窗口，或用户点"歇一下"提前结束（提前结束也出结果，按已完成次数算）。

状态机跑在检测队列；每完成一次 rep，通过线程安全状态（同 PPG 的 `NSLock` 模式）暴露给主线程；主线程 `Timer` 轮询到 `reps` 变化 → 触发一次开花/飞鸟动效 + 语音"再来一个"。

---

## 6. 取景对位（B2）就绪判定

进入活动前，自动判断"人坐好了、拍得全":

- 检测到**髋+膝+踝**关节点且置信度达标（下半身没被截）。
- 人体在画面中央区域（root.x 在 [0.3,0.7]）。
- 连续 N 帧（如 15 帧 ≈ 0.5s）稳定 → 采一段"坐态基线" → 自动进倒计时 B3。
- 未就绪 → 暖提示（"往后坐一点，让我看到您")，**不报错**。

---

## 7. 数据模型 / 存储

现有 [FallRiskRecord](LeLing/Storage/LeLingStore.swift) 已有 `reps` / `level`，**扩展**：

```
struct FallRiskRecord {
    id, date
    reps: Int
    avgSeconds: Double     // 新增
    level: String          // good/caution/risk（仅进 PDF）
    // stability: Double?   // 可选，后加
}
```

- 存储走 `LeLingStore.addFall(...)` 扩参；老人端读它只映射成暖话，PDF 读它出数字+分级+趋势。

---

## 8. 检测层 / 表现层解耦（关键架构）

- **检测层**（`nonisolated` 控制器）：只吐事件——`onRepCompleted`、`onStateChanged`、`onReady`、`onLostTracking`。不关心 UI。
- **状态机**（纯函数/独立类）：吃关节点序列，吐 reps/timing/level。**可脱离相机单测**（拿录制的关节点序列回放测），这是唯一能在没真机时验证逻辑的办法——**建议先写它并用假数据测**。
- **表现层**（SwiftUI `@MainActor` ObservableObject，仿 [PPGMeasurer](LeLing/Features/Vitals/PPGMeasurer.swift)）：轮询检测层状态 → 驱动动效/语音/文案。老人端与 PDF 是同一份 record 的两个呈现。

---

## 9. 并发要点（PLAN.md 点过的坑）

- 控制器 `nonisolated final class ... @unchecked Sendable`，自带队列，锁保护共享状态；主线程只轮询，别在 delegate 回调里碰 `@MainActor` 状态。
- Vision 请求在采集队列同步跑（`VNImageRequestHandler.perform`），注意别阻塞太久掉帧；13 mini 性能足够，但降分辨率（`.medium`/自定）保帧率。
- 真机编译重点看 Swift 6 并发报错（Sendable / actor 隔离），和 PPG 那次同类问题。

---

## 10. 鲁棒性 / 边界

| 情况 | 处理 |
|---|---|
| 光线暗/背光 | 置信度掉 → 暖提示"屋里再亮一点点"，暂停判定不报错 |
| 下半身被桌子挡 | 取景对位阶段就拦住，要求露出到脚 |
| 老人只做两三次就停 | 提前结束照样出结果，按已完成次数算（**绝不判"失败"**） |
| 完全检测不到人 | 超时(如10s)仍无人 → 温柔提示重新取景，不崩不空转 |
| 椅子太高/太矮 | 用相对基线+滞回，天然容忍；实测再调阈值 |
| 老人扶东西起立 | 允许，只影响 stability，不影响计数 |

---

## 11. 真机验证清单（到 Mac + 13 mini）

1. 前摄能起、姿态点能画出来（先做个 debug 叠加骨架的开关屏）。
2. 坐站一次能稳定计一次，不多不少（重点调 hipY 阈值 + 滞回带宽）。
3. 不同距离（1.5–2.5m）、不同椅子、不同光线各测几组。
4. 计时合理（每次 1.5–3s 量级）。
5. 与人工数的次数对齐（自己坐站 10 次，看它数几次）。
6. 分级映射对（用查到的常模，别用占位阈值）。
7. 掉帧/发热/耗电观察（30s 短测应无压力）。

---

## 12. 分阶段实现顺序（在没真机时能推进的先做）

1. **【无需真机】** 先写**状态机纯类 + 假关节点序列单测**，把坐↔站/计数/计时逻辑跑对。
2. **【需真机】** 接 Vision + 前摄，debug 骨架叠加，调置信度/阈值/滞回。
3. **【需真机】** 接状态机，验计数准确度。
4. 叠治愈动效层（开花/飞鸟）+ 语音"再来一个"+ 取景对位就绪判定。
5. 接 `LeLingStore` 存 record；分级用常模；接 PDF 呈现。
6. 边界/鲁棒性打磨 + 无障碍（VoiceOver/大字/触感）。

---

## 13. 待办/待查（写代码前先解决）

- [ ] **查 CST 分年龄/性别常模表**，替换 §1 的占位阈值。
- [ ] 阈值项（置信度、hipY 滞回带、就绪帧数、超时）全部标成常量集中放一处，方便真机调。
- [ ] 前摄镜像问题：预览与坐标是否需水平翻转，真机确认。
- [ ] 决定 `stability` 这版做不做（建议 v2.1 再做，先保计数+计时）。
```
