#!/usr/bin/env python3
"""把 ApiaryLog 里与其它 App 重名的通用类型改名。"""
import pathlib
import re

ROOT = pathlib.Path("/home/xykj211/ApiaryLog/ApiaryLog")
RENAMES = [("AppState", "ApiaryAppState"), ("AppTheme", "ApiaryTheme")]

changed = []
for p in ROOT.rglob("*.swift"):
    text = p.read_text()
    original = text
    for old, new in RENAMES:
        text = re.sub(rf"\b{old}\b", new, text)
    if text != original:
        p.write_text(text)
        changed.append(p.name)

print("已更新文件:", ", ".join(changed) if changed else "（无）")
