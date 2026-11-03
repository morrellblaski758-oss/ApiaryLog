import Foundation

enum ApiaryDates {

    static func short(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_GB")
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: date)
    }

    static func dayMonth(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_GB")
        f.setLocalizedDateFormatFromTemplate("d MMM")
        return f.string(from: date)
    }

    static func isoDay(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_GB")
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    /// "12 days ago" / "today"
    static func relativeDays(_ days: Int?) -> String {
        guard let d = days else { return "no visits yet" }
        if d <= 0 { return "today" }
        if d == 1 { return "1 day ago" }
        return "\(d) days ago"
    }

    static func kg(_ value: Double) -> String {
        String(format: "%.1f kg", value)
    }
}
