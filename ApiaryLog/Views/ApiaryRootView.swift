import SwiftUI

struct ApiaryRootView: View {
    @EnvironmentObject private var state: ApiaryAppState

    var body: some View {
        TabView {
            HiveListView()
                .tabItem { Label(ApiaryStrings.tabHives, systemImage: "square.grid.2x2") }

            ApiaryStatsView()
                .tabItem { Label(ApiaryStrings.tabStats, systemImage: "chart.bar") }

            AboutView()
                .tabItem { Label(ApiaryStrings.tabAbout, systemImage: "info.circle") }
        }
    }
}

#Preview {
    ApiaryRootView().environmentObject(ApiaryAppState())
}
