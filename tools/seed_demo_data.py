#!/usr/bin/env python3
"""生成一份演示用的 apiarylog.json，供 Codemagic 在模拟器里截商店图使用。

用法：python3 tools/seed_demo_data.py <目标路径>/apiarylog.json

注意：这只会写进模拟器沙盒，交付的 .app 里不带任何数据；新装用户第一次打开仍
是空列表（App Store 审核看到的就是真实的空状态）。
"""
import datetime as dt
import json
import pathlib
import sys
import uuid

# JSONEncoder 默认的日期策略是 .deferredToDate：距 2001-01-01 UTC 的秒数
REFERENCE = dt.datetime(2001, 1, 1, tzinfo=dt.timezone.utc)


def stamp(value: dt.datetime) -> float:
    return round((value - REFERENCE).total_seconds(), 6)


def uid() -> str:
    return str(uuid.uuid4()).upper()


TODAY = dt.datetime.now(dt.timezone.utc)


def days_ago(n):
    return TODAY - dt.timedelta(days=n, hours=n % 7)


hives = [
    {"name": "Orchard Row 1", "type": "national", "site": "Orchard", "queenYear": 2025,
     "queenMark": "blue", "notes": "Strong colony, clipped last spring."},
    {"name": "Orchard Row 2", "type": "national", "site": "Orchard", "queenYear": 2026,
     "queenMark": "white", "notes": ""},
    {"name": "Meadow Nuc", "type": "nuc", "site": "Meadow", "queenYear": 2026,
     "queenMark": "white", "notes": "Raised from Orchard Row 1."},
    {"name": "Top Bar Trial", "type": "topBar", "site": "Meadow", "queenYear": 2025,
     "queenMark": "none", "notes": "First season on bars."},
]

hive_records = []
for index, item in enumerate(hives):
    hive_records.append({
        "id": uid(),
        "name": item["name"],
        "type": item["type"],
        "site": item["site"],
        "queenYear": item["queenYear"],
        "queenMark": item["queenMark"],
        "notes": item["notes"],
        "isActive": True,
        "createdAt": stamp(days_ago(200 + index * 15)),
    })

# 每个箱子的检查记录：日期、类型、看到的框数、落螨、取蜜
plan = [
    [(3, "routine", 6, 8, 4, 2, 1, "Calm, queen seen on frame 3.", 0.0),
     (17, "routine", 7, 7, 3, 2, 5, "", 0.0),
     (31, "treatment", 5, 8, 2, 3, 22, "Oxalic vape, 3 rounds.", 0.0),
     (52, "harvest", 8, 6, 0, 2, 4, "Two supers off, capped.", 11.5)],
    [(6, "routine", 5, 7, 5, 2, 3, "Supers going on.", 0.0),
     (24, "routine", 6, 7, 4, 2, 6, "", 0.0),
     (45, "swarm", 4, 6, 2, 4, 2, "Queen cells removed, split made.", 0.0)],
    [(10, "routine", 3, 5, 1, 2, 1, "Building well for a nuc.", 0.0),
     (38, "routine", 4, 6, 2, 2, 2, "", 0.0)],
    [(8, "routine", 0, 0, 0, 3, 7, "Bars drawn, no queen seen.", 0.0),
     (29, "winter", 0, 0, 0, 3, 1, "Fondant on, entrance reduced.", 0.0)],
]

inspections = []
for hive_index, rows in enumerate(plan):
    for (ago, kind, brood, stores, supers, temper, varroa, note, honey) in rows:
        inspections.append({
            "id": uid(),
            "hiveID": hive_records[hive_index]["id"],
            "date": stamp(days_ago(ago)),
            "kind": kind,
            "queenSeen": brood > 0 and kind in ("routine", "harvest"),
            "broodFrames": brood,
            "storeFrames": stores,
            "supersAdded": supers,
            "temperament": temper,
            "varroaDrops": varroa,
            "treatment": "Oxalic vape, 3 rounds." if kind == "treatment" else "",
            "notes": note,
            "honeyKg": honey,
        })

payload = {"hives": hive_records, "inspections": inspections}

target = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else "apiarylog.json")
target.parent.mkdir(parents=True, exist_ok=True)
target.write_text(json.dumps(payload, indent=2), encoding="utf-8")
print(f"写入 {target}  蜂箱 {len(hive_records)} 个，检查记录 {len(inspections)} 条")
