import Foundation
import Combine

/// 本地存储：蜂箱与检查记录都写在 App 沙盒内的一个 JSON 文件里，不上传任何数据。
final class HiveStore: ObservableObject {
    @Published private(set) var hives: [Hive] = []
    @Published private(set) var inspections: [Inspection] = []

    private struct Payload: Codable {
        var hives: [Hive]
        var inspections: [Inspection]
    }

    private var fileURL: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("apiarylog.json")
    }

    init() { load() }

    // MARK: - 蜂箱

    func addHive(_ hive: Hive) {
        hives.append(hive)
        save()
    }

    func updateHive(_ hive: Hive) {
        if let i = hives.firstIndex(where: { $0.id == hive.id }) {
            hives[i] = hive
            save()
        }
    }

    func deleteHive(_ hive: Hive) {
        hives.removeAll { $0.id == hive.id }
        inspections.removeAll { $0.hiveID == hive.id }
        save()
    }

    func nextHiveName() -> String {
        let used = Set(hives.map { $0.name })
        var i = hives.count + 1
        while used.contains("Hive \(i)") { i += 1 }
        return "Hive \(i)"
    }

    // MARK: - 检查记录

    func addInspection(_ inspection: Inspection) {
        inspections.append(inspection)
        save()
    }

    func updateInspection(_ inspection: Inspection) {
        if let i = inspections.firstIndex(where: { $0.id == inspection.id }) {
            inspections[i] = inspection
            save()
        }
    }

    func deleteInspection(_ inspection: Inspection) {
        inspections.removeAll { $0.id == inspection.id }
        save()
    }

    func inspections(for hive: Hive) -> [Inspection] {
        inspections.filter { $0.hiveID == hive.id }.sorted { $0.date > $1.date }
    }

    func lastInspection(for hive: Hive) -> Inspection? {
        inspections(for: hive).first
    }

    // MARK: - 示例数据（首次启动可见、可一键清除）

    /// 示例记录统一用这个前缀，清除时按前缀精确删掉，不会误伤用户自己的数据。
    static let samplePrefix = "Sample — "

    var hasSampleData: Bool {
        hives.contains { $0.name.hasPrefix(HiveStore.samplePrefix) }
    }

    /// 首次启动、且本地一条记录都没有时，写入一份示例数据。
    /// 目的：审核员/新用户第一次打开就能看到完整的样子，和商店截图一致；
    /// 数据名都带 Sample 前缀，界面上有横幅说明可以一键清空。
    func loadSampleIfFirstLaunch() {
        guard hives.isEmpty else { return }
        guard !UserDefaults.standard.bool(forKey: "apiarylog.sampleSeeded") else { return }
        UserDefaults.standard.set(true, forKey: "apiarylog.sampleSeeded")
        seedSample()
    }

    func clearSampleData() {
        let ids = Set(hives.filter { $0.name.hasPrefix(HiveStore.samplePrefix) }.map { $0.id })
        guard !ids.isEmpty else { return }
        hives.removeAll { ids.contains($0.id) }
        inspections.removeAll { ids.contains($0.hiveID) }
        save()
    }

    private func seedSample() {
        let cal = Calendar.current
        let now = Date()
        func back(_ days: Int) -> Date { cal.date(byAdding: .day, value: -days, to: now) ?? now }
        let thisYear = cal.component(.year, from: now)

        let specs: [(String, HiveType, String, QueenMark, String)] = [
            ("Willow Apiary", .national, "Orchard", .yellow, "Main production colony."),
            ("Meadow Nuc", .nuc, "Meadow", .green, "Split from Willow in spring."),
            ("Top Bar Trial", .topBar, "Orchard", .none, "Comparing comb build on top bars."),
            ("Langstroth B", .langstroth, "Hill field", .white, "Second season, requeened."),
            ("Warre Two", .warre, "Hill field", .red, "Left untouched for a month."),
        ]

        var newHives: [Hive] = []
        for (i, spec) in specs.enumerated() {
            var h = Hive(name: HiveStore.samplePrefix + spec.0, type: spec.1, site: spec.2,
                         queenYear: thisYear, queenMark: spec.3)
            h.notes = spec.4
            h.createdAt = back(120 - i * 7)
            newHives.append(h)
        }

        var newInspections: [Inspection] = []
        for (i, hive) in newHives.enumerated() {
            let visits = i == 0 ? 6 : (i == 4 ? 1 : 3)
            for v in 0..<visits {
                var ins = Inspection(hiveID: hive.id)
                ins.date = back(3 + v * 9 + i * 2)
                ins.kind = v % 4 == 3 ? .harvest : (v % 3 == 2 ? .treatment : .routine)
                ins.queenSeen = v % 2 == 0
                ins.broodFrames = 4 + (v % 4)
                ins.storeFrames = 3 + (i % 3)
                ins.supersAdded = v == 2 ? 1 : 0
                ins.temperament = 2 + (v % 3)
                ins.varroaDrops = (v * 3) % 12
                ins.treatment = ins.kind == .treatment ? "Oxalic acid vapor" : ""
                ins.honeyKg = ins.kind == .harvest ? Double(2 + v) : 0
                ins.notes = v == 0 ? "Calm, good brood pattern." : ""
                newInspections.append(ins)
            }
        }

        hives = newHives
        inspections = newInspections
        save()
    }

    // MARK: - 持久化

    private func save() {
        let payload = Payload(hives: hives, inspections: inspections)
        do {
            let data = try JSONEncoder().encode(payload)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            // 本地写盘失败不应打断使用
            print("ApiaryLog save failed: \(error)")
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let payload = try? JSONDecoder().decode(Payload.self, from: data) else { return }
        hives = payload.hives
        inspections = payload.inspections
    }

    /// 供导出使用
    func snapshot() -> (hives: [Hive], inspections: [Inspection]) { (hives, inspections) }
}
