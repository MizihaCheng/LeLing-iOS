import SwiftUI
import Lottie

// MARK: - Lottie 播放器（SwiftUI 包装）
//
// ⚠️ 依赖：需在 Xcode 里加 Swift Package —— https://github.com/airbnb/lottie-spm
//    File ▸ Add Package Dependencies… 粘贴上面地址，加到 LeLing target。
//    加好之前，`import Lottie` 会报错、整个工程编译不过（正常）。
//
// 用法：LottiePlayer(name: "flower1") —— 循环播放 bundle 里的 flower1.json。

struct LottiePlayer: UIViewRepresentable {
    let name: String
    var loopMode: LottieLoopMode = .loop
    var speed: CGFloat = 1.0

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear

        let animationView = LottieAnimationView(name: name)
        animationView.loopMode = loopMode
        animationView.animationSpeed = speed
        animationView.contentMode = .scaleAspectFit
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: container.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        animationView.play()
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
