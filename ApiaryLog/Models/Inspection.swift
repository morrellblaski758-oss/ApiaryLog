import Foundation

/// 检查类型
enum InspectionKind: String, CaseIterable, Identifiable, Codable {
    case routine, swarm, treatment, harvest, winter, other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .routine:   return "Routine"
        case .swarm:     return "Swarm control"
        case .treatment: return "Treatment"
        case .harvest:   return "Harvest"
        case .winter:    return "Winter prep"
        case .other:     return "Other"
        }
    }

    var symbol: String {
        switch self {
        case .routine:   return "checklist"
        case .swarm:     return "exclamationmark.triangle"
        case .treatment: return "cross.case"
        case .harvest:   return "drop"
        case .winter:    return "snowflake"
        case .other:     return "ellipsis.circle"
        }
    }
}

/// 一次开箱检查记录
struct Inspection: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var hiveID: UUID
    var date: Date = Date()
    var kind: InspectionKind = .routine
    var queenSeen: Bool = false
    var broodFrames: Int = 0
    var storeFrames: Int = 0
    var supersAdded: Int = 0
    var temperament: Int = 3
    var varroaDrops: Int = 0
    var treatment: String = ""
    var notes: String = ""
    var honeyKg: Double = 0

    var hasTreatment: Bool { !treatment.trimmingCharacters(in: .whitespaces).isEmpty }
    var hasHarvest: Bool { honeyKg > 0 }
}
