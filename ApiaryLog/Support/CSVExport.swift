import Foundation

/// 生成 CSV（蜂箱清单 + 检查记录），写到临时目录供分享。全部本地完成。
enum CSVExport {

    static func makeFile(hives: [Hive], inspections: [Inspection]) -> URL? {
        var csv = "hive,type,site,queen_year,queen_mark,active\n"
        for h in hives {
            let site = escape(h.site)
            csv += "\(escape(h.name)),\(h.type.title),\(site),\(h.queenYear),\(h.queenMark.title),\(h.isActive ? "yes" : "no")\n"
        }

        csv += "\n"
        csv += "date,hive,kind,queen_seen,brood_frames,store_frames,supers_added,temperament,varroa_drops,treatment,honey_kg,notes\n"

        let byID = Dictionary(uniqueKeysWithValues: hives.map { ($0.id, $0.name) })
        for i in inspections.sorted(by: { $0.date < $1.date }) {
            let row = [
                ApiaryDates.isoDay(i.date),
                escape(byID[i.hiveID] ?? "unknown"),
                i.kind.title,
                i.queenSeen ? "yes" : "no",
                String(i.broodFrames),
                String(i.storeFrames),
                String(i.supersAdded),
                String(i.temperament),
                String(i.varroaDrops),
                escape(i.treatment),
                String(format: "%.2f", i.honeyKg),
                escape(i.notes)
            ].joined(separator: ",")
            csv += row + "\n"
        }

        let dir = FileManager.default.temporaryDirectory
        let url = dir.appendingPathComponent("apiary-log.csv")
        do {
            try csv.data(using: .utf8)?.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }

    private static func escape(_ s: String) -> String {
        let needsQuote = s.contains(",") || s.contains("\"") || s.contains("\n")
        let inner = s.replacingOccurrences(of: "\"", with: "\"\"")
        return needsQuote ? "\"\(inner)\"" : inner
    }
}
