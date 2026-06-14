import SwiftUI
import AVFoundation
import Combine

// MARK: - 后摄手指法 PPG：测心率 + 呼吸频率
//
// 原理：手指盖住后置摄像头 + 闪光灯，每帧画面的红色通道均值随脉搏起伏 → 得到脉搏波。
//   · 心率：脉搏波在 0.7–3.5 Hz（42–210 bpm）的主频。
//   · 呼吸：脉搏波基线随呼吸缓慢漂移，取 0.13–0.5 Hz（约 8–30 次/分）的主频。
// 频率分析用直接周期图扫描（不依赖 FFT 库，简单稳妥）。

/// 线程安全的采样缓冲。
final class PPGBuffer: @unchecked Sendable {
    private let lock = NSLock()
    private var items: [(t: Double, v: Double)] = []

    func reset() { lock.lock(); items.removeAll(); lock.unlock() }
    func append(_ t: Double, _ v: Double) { lock.lock(); items.append((t, v)); lock.unlock() }
    func snapshot() -> [(t: Double, v: Double)] { lock.lock(); let c = items; lock.unlock(); return c }
}

/// 相机控制器：跑在自己的队列上，与主线程解耦（轮询取状态，避免跨 actor 闭包）。
nonisolated final class PPGCameraController: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, @unchecked Sendable {
    private let session = AVCaptureSession()
    private var device: AVCaptureDevice?
    private let queue = DispatchQueue(label: "leling.ppg.camera")
    private let buffer = PPGBuffer()

    private let stateLock = NSLock()
    private var _fingerPresent = false
    var fingerPresent: Bool { stateLock.lock(); let v = _fingerPresent; stateLock.unlock(); return v }

    func start() {
        buffer.reset()
        queue.async { [self] in configure() }
    }

    func stop() {
        queue.async { [self] in
            if session.isRunning { session.stopRunning() }
            if let d = device, d.hasTorch {
                try? d.lockForConfiguration(); d.torchMode = .off; d.unlockForConfiguration()
            }
        }
    }

    func snapshot() -> [(t: Double, v: Double)] { buffer.snapshot() }

    private func configure() {
        session.beginConfiguration()
        session.sessionPreset = .low
        guard let dev = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: dev) else {
            session.commitConfiguration(); return
        }
        if session.canAddInput(input) { session.addInput(input) }

        let out = AVCaptureVideoDataOutput()
        out.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        out.alwaysDiscardsLateVideoFrames = true
        out.setSampleBufferDelegate(self, queue: queue)
        if session.canAddOutput(out) { session.addOutput(out) }
        session.commitConfiguration()

        device = dev
        if dev.hasTorch {
            try? dev.lockForConfiguration()
            try? dev.setTorchModeOn(level: 1.0)
            dev.unlockForConfiguration()
        }
        session.startRunning()
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pb = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        CVPixelBufferLockBaseAddress(pb, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pb, .readOnly) }
        guard let base = CVPixelBufferGetBaseAddress(pb) else { return }

        let w = CVPixelBufferGetWidth(pb)
        let h = CVPixelBufferGetHeight(pb)
        let bpr = CVPixelBufferGetBytesPerRow(pb)
        let ptr = base.assumingMemoryBound(to: UInt8.self)

        var sumR = 0.0, sumG = 0.0, n = 0.0
        let stepY = max(1, h / 16)
        let stepX = max(1, w / 16)
        var y = 0
        while y < h {
            let row = ptr + y * bpr
            var x = 0
            while x < w {
                let p = row + x * 4   // BGRA
                sumG += Double(p[1])
                sumR += Double(p[2])
                n += 1
                x += stepX
            }
            y += stepY
        }
        guard n > 0 else { return }
        let meanR = sumR / n
        let meanG = sumG / n
        let t = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
        if t.isFinite { buffer.append(t, meanR) }

        // 手指在位的简单判据：很红、绿色明显偏低（手指+闪光 → 偏红）
        stateLock.lock(); _fingerPresent = (meanR > 90 && meanR > meanG * 1.4); stateLock.unlock()
    }
}

/// 信号处理（纯函数）。
enum PPGMath {
    static func analyze(_ raw: [(t: Double, v: Double)]) -> (hr: Int, rr: Int) {
        guard raw.count > 90, let t0 = raw.first?.t, let tN = raw.last?.t, tN > t0 else { return (0, 0) }
        let fs = Double(raw.count - 1) / (tN - t0)
        guard fs > 5 else { return (0, 0) }

        var v = raw.map { $0.v }
        let mean = v.reduce(0, +) / Double(v.count)
        for i in v.indices { v[i] -= mean }

        let hrF = dominantFreq(v, fs: fs, lo: 0.7, hi: 3.5, step: 0.01)
        let rrF = dominantFreq(v, fs: fs, lo: 0.13, hi: 0.5, step: 0.005)
        return (Int((hrF * 60).rounded()), Int((rrF * 60).rounded()))
    }

    /// 在 [lo, hi] 频段里用周期图扫描找主频。
    static func dominantFreq(_ x: [Double], fs: Double, lo: Double, hi: Double, step: Double) -> Double {
        let n = x.count
        var bestF = lo, bestP = -1.0
        var f = lo
        while f <= hi {
            let w = 2 * Double.pi * f / fs
            var re = 0.0, im = 0.0
            for i in 0..<n {
                let a = w * Double(i)
                re += x[i] * cos(a)
                im += x[i] * sin(a)
            }
            let p = re * re + im * im
            if p > bestP { bestP = p; bestF = f }
            f += step
        }
        return bestF
    }
}

/// 给 SwiftUI 用的测量状态机（主线程）。
@MainActor
final class PPGMeasurer: ObservableObject {
    enum Phase { case idle, measuring, done, failed }

    @Published var phase: Phase = .idle
    @Published var progress: Double = 0
    @Published var fingerOK = false
    @Published var heartRate = 0
    @Published var respiration = 0

    let duration: Double = 30
    private let controller = PPGCameraController()
    private var startDate: Date?
    private var timer: Timer?

    func start() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            Task { @MainActor in
                guard granted else { self.phase = .failed; return }
                self.beginMeasuring()
            }
        }
    }

    private func beginMeasuring() {
        controller.start()
        startDate = Date()
        progress = 0
        phase = .measuring
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    private func tick() {
        fingerOK = controller.fingerPresent
        guard let s = startDate else { return }
        let e = Date().timeIntervalSince(s)
        progress = min(e / duration, 1)
        if e >= duration { finish() }
    }

    private func finish() {
        timer?.invalidate(); timer = nil
        let data = controller.snapshot()
        controller.stop()
        let r = PPGMath.analyze(data)
        if r.hr >= 40 && r.hr <= 200 {
            heartRate = r.hr
            respiration = (r.rr >= 6 && r.rr <= 40) ? r.rr : 0
            phase = .done
        } else {
            phase = .failed
        }
    }

    func cancel() {
        timer?.invalidate(); timer = nil
        controller.stop()
        if phase == .measuring { phase = .idle }
    }

    func reset() {
        heartRate = 0; respiration = 0; progress = 0; fingerOK = false; phase = .idle
    }
}
