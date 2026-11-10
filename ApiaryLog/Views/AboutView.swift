import SwiftUI

struct AboutView: View {
    @EnvironmentObject private var state: ApiaryAppState

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(ApiaryStrings.aboutWhatBody)
                        .font(.callout)
                } header: {
                    Text(ApiaryStrings.aboutWhat)
                }

                Section {
                    Stepper(value: $state.settings.overdueDays, in: 1...30) {
                        HStack {
                            Text("Flag a hive after")
                            Spacer()
                            Text("\(state.settings.overdueDays) days")
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                    }
                    Toggle("Show inactive hives", isOn: $state.settings.showInactiveHives)
                    Picker("Weight unit", selection: $state.settings.weightUnit) {
                        ForEach(WeightUnit.allCases) { u in
                            Text(u.title).tag(u)
                        }
                    }
                } header: {
                    Text("Settings")
                } footer: {
                    Text("These settings only affect how records are displayed and counted on this device.")
                }

                if state.store.hasSampleData {
                    Section {
                        Button("Clear sample data", role: .destructive) {
                            state.store.clearSampleData()
                        }
                    } header: {
                        Text("Sample data")
                    } footer: {
                        Text("Records whose names start with Sample are demo data. "
                             + "Clearing them does not touch anything you created yourself.")
                    }
                }

                Section {
                    Text(ApiaryStrings.aboutDataBody)
                        .font(.callout)
                } header: {
                    Text(ApiaryStrings.aboutData)
                }

                Section {
                    Text(ApiaryStrings.aboutPrivacyBody)
                        .font(.callout)
                } header: {
                    Text(ApiaryStrings.aboutPrivacy)
                }

                Section {
                    Text(ApiaryStrings.aboutDisclaimerBody)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } header: {
                    Text(ApiaryStrings.aboutDisclaimer)
                }

                Section {
                    HStack {
                        Text(ApiaryStrings.appName)
                        Spacer()
                        Text(ApiaryStrings.aboutVersion).foregroundStyle(.secondary)
                    }
                    .font(.footnote)
                }
            }
            .navigationTitle(ApiaryStrings.tabAbout)
        }
    }
}

#Preview {
    AboutView().environmentObject(ApiaryAppState())
}
