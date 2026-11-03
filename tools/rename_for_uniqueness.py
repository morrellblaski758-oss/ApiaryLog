#!/usr/bin/env python3
"""按反关联纪律重命名 ApiaryLog 里与其它 App 重名的文件/类型。"""
import pathlib
import re

ROOT = pathlib.Path("/home/xykj211/ApiaryLog")
SRC = ROOT / "ApiaryLog"
PBX = ROOT / "ApiaryLog.xcodeproj" / "project.pbxproj"

# 文件改名：旧 -> 新
FILE_RENAMES = {
    "L10n.swift": "ApiaryStrings.swift",
    "Formatters.swift": "ApiaryDates.swift",
    "RootView.swift": "ApiaryRootView.swift",
    "Stats.swift": "ApiaryMetrics.swift",
    "StatsView.swift": "ApiaryStatsView.swift",
}

# 类型/符号改名（先长后短，避免前缀误伤）
SYMBOL_RENAMES = [
    ("StatsCalculator", "ApiaryMetrics"),
    ("StatsView", "ApiaryStatsView"),
    ("RootView", "ApiaryRootView"),
    ("DateFmt", "ApiaryDates"),
    ("L10n", "ApiaryStrings"),
]

# 1) 先改文件内容（按文件名定位，避免动到别的文件）
for old_name, new_name in FILE_RENAMES.items():
    matches = list(SRC.rglob(old_name))
    if not matches:
        print(f"跳过（没找到）: {old_name}")
        continue
    for p in matches:
        text = p.read_text()
        for old, new in SYMBOL_RENAMES:
            text = re.sub(rf"\b{old}\b", new, text)
        p.write_text(text)
        print(f"内容已改: {p.relative_to(ROOT)}")

# 2) 再改文件名
for old_name, new_name in FILE_RENAMES.items():
    for p in SRC.rglob(old_name):
        target = p.with_name(new_name)
        p.rename(target)
        print(f"改名: {old_name} -> {new_name}")

# 3) 全文再兜一次（其它文件里对旧符号的引用，如 RootView() 调用）
for p in SRC.rglob("*.swift"):
    text = p.read_text()
    original = text
    for old, new in SYMBOL_RENAMES:
        text = re.sub(rf"\b{old}\b", new, text)
    if text != original:
        p.write_text(text)
        print(f"引用更新: {p.relative_to(ROOT)}")

# 4) 更新 pbxproj 里的路径
t = PBX.read_text()
for old_name, new_name in FILE_RENAMES.items():
    t = t.replace(f"path = {old_name};", f"path = {new_name};")
    t = t.replace(f"/* {old_name} */", f"/* {new_name} */")
PBX.write_text(t)
print("\npbxproj 路径已更新")

# 5) 报告
print("\n当前文件清单:")
for p in sorted(SRC.rglob("*.swift")):
    print("  ", p.name)
