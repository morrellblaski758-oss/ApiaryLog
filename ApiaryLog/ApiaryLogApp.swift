import SwiftUI

/// 全局状态：蜂箱与检查记录全部保存在本机
final class ApiaryAppState: ObservableObject {
    @Published var store = HiveStore()
    @Published var settings = AppSettings()
}

@main
struct ApiaryLogApp: App {
    @StateObject private var state = ApiaryAppState()

    var body: some Scene {
        WindowGroup {
            ApiaryRootView()
                .environmentObject(state)
                .tint(ApiaryTheme.accent)
        }
    }
}

enum ApiaryTheme {
    static let accent = Color(red: 0.85, green: 0.55, blue: 0.10)
    static let card = Color(.secondarySystemBackground)
    static let good = Color(red: 0.18, green: 0.55, blue: 0.32)
    static let warn = Color(red: 0.80, green: 0.35, blue: 0.15)
}
