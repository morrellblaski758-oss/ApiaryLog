import Foundation

/// 某个蜂箱的汇总
struct HiveSummary: Identifiable {
    var id: UUID { hive.id }
    var hive: Hive
    var inspectionCount: Int
    var lastDate: Date?
    var daysSinceLast: Int?
    var honeyKg: Double
    var lastVarroa: Int?
    var totalSupersAdded: Int
}

/// 按月统计
struct MonthCount: Identifiable {
    var id: String { key }
    var key: String        // yyyy-MM
    var label: String      // 显示用
    var count: Int
}

/// 蜂场级汇总
struct ApiarySummary {
    var activeHives: Int
    var totalHives: Int
    var inspectionCount: Int
    var honeyKg: Double
    var overdueCount: Int          // 超过设定天数未检查
    var averageIntervalDays: Int?

    static let empty = ApiarySummary(activeHives: 0, totalHives: 0, inspectionCount: 0,
                                    honeyKg: 0, overdueCount: 0, averageIntervalDays: nil)
}

enum ApiaryMetrics {

    static func summaries(hives: [Hive], inspections: [Inspection]) -> [HiveSummary] {
        let cal = Calendar.current
        let today = Date()
        return hives.map { hive in
            let list = inspections.filter { $0.hiveID == hive.id }
            let sorted = list.sorted { $0.date > $1.date }
            let last = sorted.first
            let days = last.map { cal.dateComponents([.day], from: $0.date, to: today).day ?? 0 }
            return HiveSummary(
                hive: hive,
                inspectionCount: list.count,
                lastDate: last?.date,
                daysSinceLast: days,
                honeyKg: list.reduce(0) { $0 + $1.honeyKg },
                lastVarroa: sorted.first(where: { $0.varroaDrops > 0 })?.varroaDrops,
                totalSupersAdded: list.reduce(0) { $0 + $1.supersAdded }
            )
        }
        .sorted { $0.hive.name.localizedStandardCompare($1.hive.name) == .orderedAscending }
    }

    static func apiary(hives: [Hive], inspections: [Inspection], overdueDays: Int) -> ApiarySummary {
        guard !hives.isEmpty || !inspections.isEmpty else { return .empty }
        let cal = Calendar.current
        let today = Date()
        var overdue = 0
        var intervals: [Int] = []

        for hive in hives where hive.isActive {
            let dates = inspections.filter { $0.hiveID == hive.id }.map { $0.date }.sorted(by: >)
            guard let last = dates.first else {
                overdue += 1
                continue
            }
            if let days = cal.dateComponents([.day], from: last, to: today).day, days > overdueDays {
                overdue += 1
            }
            for (a, b) in zip(dates, dates.dropFirst()) {
                if let d = cal.dateComponents([.day], from: b, to: a).day, d > 0 {
                    intervals.append(d)
                }
            }
        }

        let avg = intervals.isEmpty ? nil : intervals.reduce(0, +) / intervals.count
        return ApiarySummary(
            activeHives: hives.filter { $0.isActive }.count,
            totalHives: hives.count,
            inspectionCount: inspections.count,
            honeyKg: inspections.reduce(0) { $0 + $1.honeyKg },
            overdueCount: overdue,
            averageIntervalDays: avg
        )
    }

    /// 最近 months 个月的检查次数（缺失月份补 0，保证 X 轴连续）
    static func monthlyCounts(inspections: [Inspection], months: Int = 6) -> [MonthCount] {
        let cal = Calendar.current
        let now = Date()
        var result: [MonthCount] = []
        for offset in stride(from: months - 1, through: 0, by: -1) {
            guard let monthDate = cal.date(byAdding: .month, value: -offset, to: now) else { continue }
            let comps = cal.dateComponents([.year, .month], from: monthDate)
            let key = String(format: "%04d-%02d", comps.year ?? 0, comps.month ?? 0)
            let count = inspections.filter {
                let c = cal.dateComponents([.year, .month], from: $0.date)
                return c.year == comps.year && c.month == comps.month
            }.count
            let label = String(format: "%02d", comps.month ?? 0)
            result.append(MonthCount(key: key, label: label, count: count))
        }
        return result
    }
}
