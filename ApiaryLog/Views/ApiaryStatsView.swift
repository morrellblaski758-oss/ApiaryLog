import SwiftUI
import Charts

struct ApiaryStatsView: View {
    @EnvironmentObject private var state: ApiaryAppState
    @State private var export: ExportItem?

    private struct ExportItem: Identifiable {
        let id = UUID()
        let url: URL
    }

    private var summary: ApiarySummary {
        ApiaryMetrics.apiary(hives: state.store.hives,
                               inspections: state.store.inspections,
                               overdueDays: state.settings.overdueDays)
    }

    private var monthly: [MonthCount] {
        ApiaryMetrics.monthlyCounts(inspections: state.store.inspections, months: 6)
    }

    private var hiveSummaries: [HiveSummary] {
        ApiaryMetrics.summaries(hives: state.store.hives, inspections: state.store.inspections)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        tile(ApiaryStrings.activeHives, "\(summary.activeHives)")
                        tile(ApiaryStrings.totalVisits, "\(summary.inspectionCount)")
                        tile(ApiaryStrings.honeyTotal, String(format: "%.1f %@",
                                                     state.settings.weightUnit.convert(fromKg: summary.honeyKg),
                                                     state.settings.weightUnit.suffix))
                        tile(ApiaryStrings.overdue, "\(summary.overdueCount)")
                    }
                    .padding(.vertical, 4)
                }

                Section {
                    if monthly.allSatisfy({ $0.count == 0 }) {
                        Text("No inspections recorded yet.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        Chart(monthly) { m in
                            BarMark(
                                x: .value("Month", m.label),
                                y: .value("Inspections", m.count)
                            )
                            .foregroundStyle(ApiaryTheme.accent)
                            .cornerRadius(4)
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { value in
                                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
                                AxisValueLabel {
                                    if let v = value.as(Int.self) {
                                        Text(String(v)).font(.caption2)
                                    }
                                }
                            }
                        }
                        .frame(height: 170)
                    }
                } header: {
                    Text(ApiaryStrings.visitsByMonth)
                }

                Section {
                    if let avg = summary.averageIntervalDays {
                        HStack {
                            Text(ApiaryStrings.avgInterval)
                            Spacer()
                            Text("\(avg)").monospacedDigit().foregroundStyle(.secondary)
                        }
                    }
                    ForEach(hiveSummaries) { s in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(s.hive.name).font(.subheadline)
                                Text("\(s.inspectionCount) visits · \(ApiaryDates.relativeDays(s.daysSinceLast))")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(String(format: "%.1f %@",
                                        state.settings.weightUnit.convert(fromKg: s.honeyKg),
                                        state.settings.weightUnit.suffix))
                                .font(.caption)
                                .monospacedDigit()
                                .foregroundStyle(s.honeyKg > 0 ? ApiaryTheme.accent : Color.secondary)
                        }
                    }
                } header: {
                    Text(ApiaryStrings.perHive)
                }

                Section {
                    Button {
                        if let url = CSVExport.makeFile(hives: state.store.hives,
                                                        inspections: state.store.inspections) {
                            export = ExportItem(url: url)
                        }
                    } label: {
                        Label(ApiaryStrings.exportCsv, systemImage: "square.and.arrow.up")
                    }
                    .disabled(state.store.hives.isEmpty && state.store.inspections.isEmpty)
                } footer: {
                    Text(ApiaryStrings.exportHint)
                }
            }
            .navigationTitle(ApiaryStrings.statsTitle)
            .sheet(item: $export) { item in
                NavigationStack {
                    VStack(spacing: 18) {
                        Image(systemName: "tablecells")
                            .font(.system(size: 40))
                            .foregroundStyle(ApiaryTheme.accent)
                        Text("apiary-log.csv")
                            .font(.headline)
                        ShareLink(item: item.url) {
                            Label(ApiaryStrings.exportCsv, systemImage: "square.and.arrow.up")
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") { export = nil }
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }

    private func tile(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.weight(.semibold))
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(ApiaryTheme.card))
    }
}

#Preview {
    ApiaryStatsView().environmentObject(ApiaryAppState())
}
