import SwiftUI

// MARK: - 本地存储（健康自查记录，存在本机 JSON，不上传）

struct VitalsRecord: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var heartRate: Int
    var respiration: Int
}

struct FallRiskRecord: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var reps: Int
    var level: String   // good / caution / risk
}

@MainActor
final class LeLingStore: ObservableObject {
    @Published private(set) var vitals: [VitalsRecord] = []
    @Published private(set) var falls: [FallRiskRecord] = []

    private let fileURL: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("leling_records.json")
    }()

    init() { load() }

    func addVitals(heartRate: Int, respiration: Int) {
        vitals.insert(VitalsRecord(date: Date(), heartRate: heartRate, respiration: respiration), at: 0)
        save()
    }

    func addFall(reps: Int, level: String) {
        falls.insert(FallRiskRecord(date: Date(), reps: reps, level: level), at: 0)
        save()
    }

    // MARK: 持久化

    private struct Payload: Codable {
        var vitals: [VitalsRecord]
        var falls: [FallRiskRecord]
    }

    private func save() {
        let payload = Payload(vitals: vitals, falls: falls)
        if let data = try? JSONEncoder().encode(payload) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let payload = try? JSONDecoder().decode(Payload.self, from: data) else { return }
        vitals = payload.vitals
        falls = payload.falls
    }
}
