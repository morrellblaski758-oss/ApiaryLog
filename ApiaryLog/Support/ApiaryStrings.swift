import Foundation

/// 界面文案集中管理（当前为英文本，后续加语言时替换实现即可）
enum ApiaryStrings {
    static let appName = "Apiary Log"

    // Tabs
    static let tabHives = "Hives"
    static let tabStats = "Stats"
    static let tabAbout = "About"

    // Lists
    static let hives = "Your hives"
    static let addHive = "Add hive"
    static let editHive = "Edit hive"
    static let noHives = "No hives yet. Add your first one to start keeping records."
    static let inspections = "Inspections"
    static let addInspection = "Add inspection"
    static let editInspection = "Edit inspection"
    static let noInspections = "No inspections recorded for this hive yet."
    static let deleteHive = "Delete hive and its records"

    // Hive fields
    static let name = "Name"
    static let type = "Type"
    static let site = "Apiary / site"
    static let queenYear = "Queen year"
    static let queenMark = "Queen mark"
    static let notes = "Notes"
    static let active = "Active"
    static let save = "Save"
    static let cancel = "Cancel"

    // Inspection fields
    static let date = "Date"
    static let kind = "Type of visit"
    static let queenSeen = "Queen seen"
    static let broodFrames = "Brood frames"
    static let storeFrames = "Stores frames"
    static let supersAdded = "Supers added"
    static let temperament = "Temperament"
    static let varroa = "Varroa drop (board)"
    static let treatment = "Treatment"
    static let honey = "Honey taken"
    static let temperamentCalm = "Calm"
    static let temperamentFiery = "Defensive"
    static let optionalHint = "Optional"

    // Stats
    static let statsTitle = "Apiary overview"
    static let activeHives = "Active hives"
    static let totalVisits = "Inspections"
    static let honeyTotal = "Honey recorded"
    static let overdue = "Need checking"
    static let avgInterval = "Avg. days between visits"
    static let visitsByMonth = "Inspections, last 6 months"
    static let perHive = "Per hive"
    static let exportCsv = "Export CSV"
    static let exportHint = "Creates a spreadsheet of hives and inspections to share or save."
    static let never = "—"

    // About
    static let aboutWhat = "What this app does"
    static let aboutWhatBody = "Apiary Log keeps a record of your hives and every inspection: what you saw, how many brood and stores frames, temperament, varroa drop, treatments and any honey taken. It is a notebook, not an advisor — it does not diagnose colony health or recommend treatments."
    static let aboutPrivacy = "Privacy"
    static let aboutPrivacyBody = "Everything you enter stays on this device. The app does not create an account, does not connect to the internet, and includes no analytics or advertising. Deleting the app deletes your records."
    static let aboutDisclaimer = "Disclaimer"
    static let aboutDisclaimerBody = "This app is a record-keeping tool. It does not provide veterinary or husbandry advice. For colony health decisions, follow your local beekeeping association guidance and, where relevant, the advice of a suitably qualified professional. Varroa counts and treatment notes are recorded exactly as you enter them."
    static let aboutData = "Data"
    static let aboutDataBody = "Records are stored in a single file inside the app's own storage. Use Export CSV to get a copy you can open in Numbers, Excel or a text editor."
    static let aboutVersion = "Version 1.0"
}
