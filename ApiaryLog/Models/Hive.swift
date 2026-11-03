import Foundation

/// 蜂箱类型
enum HiveType: String, CaseIterable, Identifiable, Codable {
    case national, langstroth, warre, topBar, nuc, other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .national:   return "National"
        case .langstroth: return "Langstroth"
        case .warre:      return "Warre"
        case .topBar:     return "Top Bar"
        case .nuc:        return "Nuc"
        case .other:      return "Other"
        }
    }
}

/// 蜂王标记色（国际惯例：按年份尾数选色）
enum QueenMark: String, CaseIterable, Identifiable, Codable {
    case white, yellow, red, green, blue, none

    var id: String { rawValue }

    var title: String {
        switch self {
        case .white:  return "White"
        case .yellow: return "Yellow"
        case .red:    return "Red"
        case .green:  return "Green"
        case .blue:   return "Blue"
        case .none:   return "Not marked"
        }
    }
}

/// 一个蜂箱
struct Hive: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var type: HiveType = .national
    var site: String = ""
    var queenYear: Int = Calendar.current.component(.year, from: Date())
    var queenMark: QueenMark = .none
    var notes: String = ""
    var isActive: Bool = true
    var createdAt: Date = Date()

    static func new(index: Int) -> Hive {
        Hive(
            name: "Hive \(index)",
            type: .national,
            site: "",
            queenYear: Calendar.current.component(.year, from: Date())
        )
    }
}
