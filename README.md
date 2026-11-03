# Apiary Log

A local record book for beekeepers: hives, inspections, treatments and honey yields.
Pure SwiftUI, iOS 17+, **fully offline** — no account, no network, no third-party SDKs, no ads, no in-app purchases.

## Features

- **Hives** — name, type (National / Langstroth / Warre / Top Bar / Nuc / Other), apiary site, queen year, queen mark, notes, active flag
- **Inspections** — date, visit type, queen seen, brood frames, stores frames, supers added, temperament (1–5), varroa drop, treatment text, honey taken (kg), notes
- **Hive detail** — per-hive visit count, honey total, last visit, full chronological record; tap to edit, swipe to delete
- **Stats** — active hives, total inspections, honey recorded, hives needing attention, average days between visits, inspections for the last 6 months (bar chart), per-hive breakdown
- **Overdue flag** — a hive is flagged when it has not been inspected for more than the number of days set in About → Settings
- **CSV export** — hives and inspections into one spreadsheet file via the iOS share sheet

Settings stored locally: overdue threshold, show/hide inactive hives, kg or lb.

## Structure

```
ApiaryLog.xcodeproj/           hand-maintained pbxproj
ApiaryLog/
  ApiaryLogApp.swift           @main, AppState, AppTheme
  Models/
    Hive.swift                 HiveType, QueenMark, Hive
    Inspection.swift           InspectionKind, Inspection
    HiveStore.swift            JSON persistence in the app sandbox
    Stats.swift                HiveSummary, ApiarySummary, monthly counts
    AppSettings.swift          local preferences
  Support/
    CSVExport.swift            CSV generation to a temp file
    Formatters.swift           date and number formatting
    L10n.swift                 all user-facing strings (English)
  Views/
    RootView.swift             TabView shell
    HiveListView.swift         hive list + hive editor
    HiveDetailView.swift       hive card + inspection records
    InspectionFormView.swift   new / edit inspection
    StatsView.swift            dashboard, chart, CSV export
    AboutView.swift            settings, privacy, disclaimer
  Resources/
    Assets.xcassets/           AppIcon (1024, no alpha)
codemagic.yaml                 compile-check / ios-build / demo-capture
support.html, privacy.html     App Store support + privacy pages
tools/                         icon generator, self-check
```

## Bundle identifier (already set)

`com.iskenderergen.apiarylog` with team `A2FJYFNGJ9`, applied in three places:

1. `ApiaryLog.xcodeproj/project.pbxproj` (Debug and Release)
2. `codemagic.yaml` → `ios_signing.bundle_identifier`
3. `codemagic.yaml` → `app-store-connect fetch-signing-files`

The App ID must already exist in the client's developer account, and the bundle ID cannot be changed
after the first release.

## Build

Cloud-only, no Mac required:

1. Push the **contents** of this folder to a GitHub repository
2. Codemagic → Add application → Native iOS → `codemagic.yaml`
3. Settings → Integrations → Developer Portal → add the App Store Connect API key
4. Settings → Environment variables → create a group (e.g. `appstore_creds`) with `APP_STORE_CONNECT_PRIVATE_KEY` (the `.p8` contents, marked Secret)
5. Run `compile-check` first, then `ios-build`

## Self-check before delivery

```
python3 tools/selfcheck.py
```

Verifies: every Swift file registered in the pbxproj exists at the path its group implies, brackets balance, bundle ID consistent, no networking / no third-party SDK / no StoreKit, icon is 1024×1024 with no alpha.

## App Review Notes (paste into App Store Connect)

> Apiary Log is a record-keeping app for beekeepers. It has no account, no login, makes no network requests and requests no system permissions.
>
> To verify: open the app → tap **+** to add a hive (name, type, optional site and notes) → open the hive → tap the ••• menu → **Add inspection** to record a visit (date, visit type, queen seen, brood/store frames, supers added, temperament, varroa drop, treatment, honey taken) → the **Stats** tab summarises the apiary and exports everything as a CSV file.
>
> All records are stored locally on the device in a single file. Nothing is uploaded. There are no in-app purchases, no subscriptions and no advertising.

## Not included on purpose

No networking layer, no third-party dependencies, no permissions, no StoreKit, no debug hooks in the release build.
