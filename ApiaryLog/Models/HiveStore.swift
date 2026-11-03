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
