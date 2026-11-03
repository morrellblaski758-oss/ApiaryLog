import SwiftUI

struct HiveListView: View {
    @EnvironmentObject private var state: ApiaryAppState
    @State private var showingNewHive = false
    @State private var editingHive: Hive?

    private var summaries: [HiveSummary] {
        let all = ApiaryMetrics.summaries(hives: state.store.hives, inspections: state.store.inspections)
        return state.settings.showInactiveHives ? all : all.filter { $0.hive.isActive }
    }

    var body: some View {
        NavigationStack {
            Group {
                if state.store.hives.isEmpty {
                    emptyState
                } else {
                    List {
                        Section {
                            ForEach(summaries) { summary in
                                NavigationLink {
                                    HiveDetailView(hive: summary.hive)
                                } label: {
                                    row(summary)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        state.store.deleteHive(summary.hive)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        editingHive = summary.hive
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                            }
                        } header: {
                            Text(ApiaryStrings.hives)
                        }
                    }
                }
            }
            .navigationTitle(ApiaryStrings.appName)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNewHive = true
                    } label: {
                        Label(ApiaryStrings.addHive, systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewHive) {
                HiveEditorView(hive: .new(index: state.store.hives.count + 1), isNew: true) { hive in
                    state.store.addHive(hive)
                }
            }
            .sheet(item: $editingHive) { hive in
                HiveEditorView(hive: hive, isNew: false) { updated in
                    state.store.updateHive(updated)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 46))
                .foregroundStyle(ApiaryTheme.accent)
            Text(ApiaryStrings.noHives)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 40)
            Button(ApiaryStrings.addHive) { showingNewHive = true }
                .buttonStyle(.borderedProminent)
        }
    }

    private func row(_ s: HiveSummary) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 6) {
                Text(s.hive.name).font(.headline)
                if !s.hive.isActive {
                    Text("inactive")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.secondary.opacity(0.18)))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if s.honeyKg > 0 {
                    Text("\(state.settings.weightUnit.convert(fromKg: s.honeyKg), specifier: "%.1f") \(state.settings.weightUnit.suffix)")
                        .font(.caption)
                        .foregroundStyle(ApiaryTheme.accent)
                }
            }
            HStack(spacing: 10) {
                Text(s.hive.type.title)
                Text("·")
                Text(ApiaryDates.relativeDays(s.daysSinceLast))
                if let v = s.lastVarroa, v > 0 {
                    Text("·")
                    Text("varroa \(v)")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

/// 新建 / 编辑蜂箱
struct HiveEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var state: ApiaryAppState

    @State var hive: Hive
    var isNew: Bool
    var onSave: (Hive) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text(ApiaryStrings.name)
                        Spacer()
                        TextField("Hive 1", text: $hive.name)
                            .multilineTextAlignment(.trailing)
                    }
                    Picker(ApiaryStrings.type, selection: $hive.type) {
                        ForEach(HiveType.allCases) { t in
                            Text(t.title).tag(t)
                        }
                    }
                    HStack {
                        Text(ApiaryStrings.site)
                        Spacer()
                        TextField("optional", text: $hive.site)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section {
                    Stepper(value: $hive.queenYear, in: 2000...2100) {
                        HStack {
                            Text(ApiaryStrings.queenYear)
                            Spacer()
                            Text(String(hive.queenYear)).foregroundStyle(.secondary).monospacedDigit()
                        }
                    }
                    Picker(ApiaryStrings.queenMark, selection: $hive.queenMark) {
                        ForEach(QueenMark.allCases) { m in
                            Text(m.title).tag(m)
                        }
                    }
                }

                Section {
                    Toggle(ApiaryStrings.active, isOn: $hive.isActive)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(ApiaryStrings.notes).font(.subheadline)
                        TextField("optional", text: $hive.notes, axis: .vertical)
                            .lineLimit(3...6)
                    }
                }
            }
            .navigationTitle(isNew ? ApiaryStrings.addHive : ApiaryStrings.editHive)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(ApiaryStrings.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(ApiaryStrings.save) {
                        onSave(hive)
                        dismiss()
                    }
                    .disabled(hive.name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
