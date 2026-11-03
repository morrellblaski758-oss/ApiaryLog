import SwiftUI

/// 新建 / 编辑一次检查记录
struct InspectionFormView: View {
    @Environment(\.dismiss) private var dismiss

    let hiveID: UUID
    var existing: Inspection?
    var onSave: (Inspection) -> Void

    @State private var draft: Inspection

    init(hiveID: UUID, existing: Inspection?, onSave: @escaping (Inspection) -> Void) {
        self.hiveID = hiveID
        self.existing = existing
        self.onSave = onSave
        _draft = State(initialValue: existing ?? Inspection(hiveID: hiveID))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker(ApiaryStrings.date, selection: $draft.date, displayedComponents: .date)
                    Picker(ApiaryStrings.kind, selection: $draft.kind) {
                        ForEach(InspectionKind.allCases) { k in
                            Label(k.title, systemImage: k.symbol).tag(k)
                        }
                    }
                }

                Section {
                    Toggle(ApiaryStrings.queenSeen, isOn: $draft.queenSeen)

                    Stepper(value: $draft.broodFrames, in: 0...20) {
                        HStack {
                            Text(ApiaryStrings.broodFrames)
                            Spacer()
                            Text(String(draft.broodFrames)).monospacedDigit().foregroundStyle(.secondary)
                        }
                    }
                    Stepper(value: $draft.storeFrames, in: 0...20) {
                        HStack {
                            Text(ApiaryStrings.storeFrames)
                            Spacer()
                            Text(String(draft.storeFrames)).monospacedDigit().foregroundStyle(.secondary)
                        }
                    }
                    Stepper(value: $draft.supersAdded, in: 0...6) {
                        HStack {
                            Text(ApiaryStrings.supersAdded)
                            Spacer()
                            Text(String(draft.supersAdded)).monospacedDigit().foregroundStyle(.secondary)
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(ApiaryStrings.temperament)
                            Spacer()
                            Text(temperamentLabel)
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: Binding(
                            get: { Double(draft.temperament) },
                            set: { draft.temperament = Int($0.rounded()) }
                        ), in: 1...5, step: 1)
                        HStack {
                            Text(ApiaryStrings.temperamentCalm).font(.caption2)
                            Spacer()
                            Text(ApiaryStrings.temperamentFiery).font(.caption2)
                        }
                        .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Stepper(value: $draft.varroaDrops, in: 0...200, step: 1) {
                        HStack {
                            Text(ApiaryStrings.varroa)
                            Spacer()
                            Text(String(draft.varroaDrops)).monospacedDigit().foregroundStyle(.secondary)
                        }
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text(ApiaryStrings.treatment).font(.subheadline)
                        TextField(ApiaryStrings.optionalHint, text: $draft.treatment, axis: .vertical)
                            .lineLimit(2...4)
                    }
                }

                Section {
                    HStack {
                        Text(ApiaryStrings.honey)
                        Spacer()
                        TextField("0", value: $draft.honeyKg, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: 90)
                        Text("kg").foregroundStyle(.secondary)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text(ApiaryStrings.notes).font(.subheadline)
                        TextField(ApiaryStrings.optionalHint, text: $draft.notes, axis: .vertical)
                            .lineLimit(3...6)
                    }
                }
            }
            .navigationTitle(existing == nil ? ApiaryStrings.addInspection : ApiaryStrings.editInspection)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(ApiaryStrings.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(ApiaryStrings.save) {
                        onSave(draft)
                        dismiss()
                    }
                }
            }
        }
    }

    private var temperamentLabel: String {
        switch draft.temperament {
        case 1: return "1 · very calm"
        case 2: return "2 · calm"
        case 3: return "3 · typical"
        case 4: return "4 · defensive"
        default: return "5 · very defensive"
        }
    }
}
