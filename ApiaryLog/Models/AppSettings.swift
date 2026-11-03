import Foundation
import Combine

/// 少量本地偏好设置（同样只存在本机）
struct AppSettings: Codable, Equatable {
    var defaultSite: String = ""
    var overdueDays: Int = 9          // 超过多少天未检查算"待检查"
    var showInactiveHives: Bool = true
    var weightUnit: WeightUnit = .kg
}

enum WeightUnit: String, CaseIterable, Identifiable, Codable {
    case kg, lb
    var id: String { rawValue }
    var title: String { self == .kg ? "Kilograms" : "Pounds" }
    var suffix: String { self == .kg ? "kg" : "lb" }

    func convert(fromKg value: Double) -> Double {
        self == .kg ? value : value * 2.2046226
    }
}
