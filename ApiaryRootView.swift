import SwiftUI

struct ApiaryRootView: View {
    @EnvironmentObject private var state: ApiaryAppState
    @State private var selectedTab: Int

    init() {
        var initial = 0
        #if DEBUG
        // 仅用于云端截图：SIMCTL_CHILD_APIARYLOG_TAB 指定初始标签页。
        // Release 包里这段不存在，审核看到的永远是默认的 Hives 页。
        if let raw = ProcessInfo.processInfo.environment["APIARYLOG_TAB"], let value = Int(raw) {
            initial = value
        }
        #endif
        _selectedTab = State(initialValue: initial)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HiveListView()
                .tabItem { Label(ApiaryStrings.tabHives, systemImage: "square.grid.2x2") }
                .tag(0)

            ApiaryStatsView()
                .tabItem { Label(ApiaryStrings.tabStats, systemImage: "chart.bar") }
                .tag(1)

            AboutView()
                .tabItem { Label(ApiaryStrings.tabAbout, systemImage: "info.circle") }
                .tag(2)
        }
    }
}

#Preview {
    ApiaryRootView().environmentObject(ApiaryAppState())
}
