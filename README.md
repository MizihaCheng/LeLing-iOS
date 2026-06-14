# 乐龄守护 (LeLing)

> 一部旧手机、对着摄像头，就能给老人做**基础健康自查**和**跌倒风险评估**，结果自动生成 AI 健康周报、一键发给子女。**零额外硬件，专为老人设计。**

参加 **Apple 移动应用创新赛 (MACC)** 的原创选题。脱胎于 FitLog 的代码底座（本地存储 / Swift Charts / 日历 / DeepSeek AI / PDF·CSV 导出 / 摄像头信号处理），但是**全新的产品与仓库**，不是健身 app 的移植。

---

## 核心三件

| 功能 | 技术 | 状态 |
|---|---|---|
| ⭐️ **跌倒风险评估** | Apple Vision 人体姿态估计，跑临床「30 秒坐站测试」 | 占位（第 2 步） |
| **心率 / 呼吸自查** | 人脸 rPPG（前摄拍脸约 30s，迁移 FitLog 信号处理） | 占位（第 3 步） |
| **AI 健康周报 + 发子女** | DeepSeek 总结 + PDF / 分享 | 占位（第 4 步） |

定位「**健康筛查与趋势提示，非医疗诊断**」。

---

## 目录结构

```
LeLing-iOS/
├─ LeLing.xcodeproj/          # 单 App target，文件系统自动同步（放进 LeLing/ 的 .swift 自动编译）
├─ LeLing/
│  ├─ App/                    # @main 入口 + 适老 Tab 外壳
│  ├─ Theme/                  # SeniorTheme：高对比配色 + 超大字号 + 大按钮
│  ├─ Features/
│  │  ├─ Home/                # 首页：今日概览 + AI 周报摘要
│  │  ├─ SelfCheck/           # 自查入口（跌倒风险 / 心率呼吸）
│  │  ├─ FallRisk/            # ⭐️ 跌倒风险评估（Vision，星功能）
│  │  ├─ Vitals/             # 心率 / 呼吸（人脸 rPPG）
│  │  ├─ Trends/              # 趋势图 + 日历
│  │  └─ Profile/             # 提醒 / 导出发子女 / 关于
│  └─ Assets.xcassets/
├─ PLAN.md                    # 分步开发计划与进度
└─ 方案-适老健康自查App.md      # 原始选题方案（pitch / 竞品 / 决策背景）
```

> 当前为**第 0 步：空骨架**。所有 Features 页都是占位卡片，但 Tab 外壳、适老主题、Xcode 工程都已就绪，Mac 上 ⌘R 能直接跑起来。

---

## 开发工作流（沿用 FitLog）

Windows 改码 + push → Mac `git pull` + Xcode ⌘R 真机验证。
**摄像头 + Vision 必须真机验证**（模拟器没相机）。

```
# Windows 端：装好后初始化仓库
cd D:\MyAIProject\LeLing-iOS
git init && git add -A && git commit -m "第0步：空骨架 + 适老主题"
```

进度与下一步见 [PLAN.md](PLAN.md)。
