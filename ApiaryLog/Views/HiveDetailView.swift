import SwiftUI

struct HiveDetailView: View {
    @EnvironmentObject private var state: ApiaryAppState
    let hive: Hive

    @State private var showingNewInspection = false
    @State private var editingInspection: Inspection?
    @State private var editingHive = false

    private var currentHive: Hive {
        state.store.hives.first(where: { $0.id == hive.id }) ?? hive
    }

    private var records: [Inspection] {
        state.store.inspections(for: currentHive)
    }

    var body: some View {
        List {
            Section {
                hiveCard
            }

            Section {
                if records.isEmpty {
                    Text(ApiaryStrings.noInspections)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(records) { record in
                        Button {
                            editingInspection = record
                        } label: {
                            inspectionRow(record)
                        }
                        .buttonStyle(.plain)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                state.store.deleteInspection(record)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            } header: {
                Text(ApiaryStrings.inspections)
            } footer: {
                Text("Tap a record to edit it.")
                    .font(.caption2)
            }
        }
        .navigationTitle(currentHive.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showingNewInspection = true
                    } label: {
                        Label(ApiaryStrings.addInspection, systemImage: "plus")
                    }
                    Button {
                        editingHive = true
                    } label: {
                        Label(ApiaryStrings.editHive, systemImage: "pencil")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingNewInspection) {
            InspectionFormView(hiveID: currentHive.id, existing: nil) { record in
                state.store.addInspection(record)
            }
        }
        .sheet(item: $editingInspection) { record in
            InspectionFormView(hiveID: currentHive.id, existing: record) { updated in
                state.store.updateInspection(updated)
            }
        }
        .sheet(isPresented: $editingHive) {
            HiveEditorView(hive: currentHive, isNew: false) { updated in
                state.store.updateHive(updated)
            }
        }
    }

    private var hiveCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(currentHive.type.title)
                        .font(.subheadline.weight(.semibold))
                    if !currentHive.site.isEmpty {
                        Text(currentHive.site)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 3) {
                    Text("Queen \(String(currentHive.queenYear))")
                        .font(.caption)
                    Text(currentHive.queenMark.title)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            HStack(spacing: 18) {
                metric("Visits", String(records.count))
                metric("Honey", String(format: "%.1f kg", records.reduce(0) { $0 + $1.honeyKg }))
                if let last = records.first {
                    metric("Last visit", ApiaryDates.dayMonth(last.date))
                }
            }

            if !currentHive.notes.isEmpty {
                Text(currentHive.notes)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func metric(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
        }
    }

    private func inspectionRow(_ r: Inspection) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: r.kind.symbol)
                .font(.subheadline)
                .foregroundStyle(ApiaryTheme.accent)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(r.kind.title).font(.subheadline.weight(.medium))
                    Spacer()
                    Text(ApiaryDates.dayMonth(r.date))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: 8) {
                    if r.queenSeen {
                        Text("queen seen").foregroundStyle(ApiaryTheme.good)
                    } else {
                        Text("queen not seen")
                    }
                    Text("· brood \(r.broodFrames)")
                    Text("· stores \(r.storeFrames)")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)

                if r.hasTreatment || r.hasHarvest || r.varroaDrops > 0 {
                    HStack(spacing: 8) {
                        if r.varroaDrops > 0 { Text("varroa \(r.varroaDrops)") }
                        if r.hasTreatment { Text("treated") }
                        if r.hasHarvest { Text(String(format: "%.1f kg", r.honeyKg)) }
                    }
                    .font(.caption2)
                    .foregroundStyle(ApiaryTheme.warn)
                }

                if !r.notes.isEmpty {
                    Text(r.notes)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, 2)
    }
}
