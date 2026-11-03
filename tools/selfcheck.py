#!/usr/bin/env python3
"""Apiary Log 交付前自检。"""
import pathlib
import re
import sys

ROOT = pathlib.Path("/home/xykj211/ApiaryLog")
NAME = "ApiaryLog"
SRC = ROOT / NAME
PBX = ROOT / f"{NAME}.xcodeproj" / "project.pbxproj"

ok = True


def fail(m):
    global ok
    ok = False
    print("  ❌", m)


def good(m):
    print("  ✅", m)


print("=== 1. 源文件与工程登记一致 ===")
disk = sorted(p.name for p in SRC.rglob("*.swift"))
t = PBX.read_text()
registered = sorted(set(re.findall(r"path = ([A-Za-z0-9_]+\.swift);", t)))
print(f"  磁盘 {len(disk)}: {', '.join(disk)}")
print(f"  工程 {len(registered)}: {', '.join(registered)}")
if disk == registered:
    good("一致")
else:
    fail(f"不一致 → 仅磁盘 {sorted(set(disk) - set(registered))} / 仅工程 {sorted(set(registered) - set(disk))}")

print("\n=== 2. 组路径与磁盘位置一致 ===")
groups = {}
for m in re.finditer(r"([A-F0-9]{24}) /\* (\w+) \*/ = \{\s*isa = PBXGroup;(.*?)\};", t, re.S):
    gid, gname, body = m.groups()
    pth = re.search(r"path = ([^;]+);", body)
    groups[gid] = (gname, pth.group(1) if pth else "")

refs = dict(re.findall(r"([A-F0-9]{24}) /\* [^*]+ \*/ = \{isa = PBXFileReference;[^}]*?path = ([^;]+);", t))
bad = []
for gid, (gname, gpath) in groups.items():
    block = re.search(rf"{gid} /\* {gname} \*/ = \{{.*?\}};", t, re.S)
    if not block:
        continue
    for ref in re.findall(r"([A-F0-9]{24}) /\*", block.group(0)):
        fn = refs.get(ref)
        if not fn or not fn.endswith(".swift"):
            continue
        base = ROOT / gpath if gname == NAME else ROOT / NAME / gpath
        if not (base / fn).exists():
            bad.append(f"{gname}/{fn}")
print("  路径不一致:", bad if bad else "无")
if not bad:
    good("全部对得上")

print("\n=== 3. 括号配平（去注释/字符串）===")
for f in SRC.rglob("*.swift"):
    raw = f.read_text()
    body = re.sub(r'"(\\.|[^"\\])*"', '""', raw)
    body = re.sub(r"//[^\n]*", "", body)
    body = re.sub(r"/\*.*?\*/", "", body, flags=re.S)
    for a, b in (("{", "}"), ("(", ")"), ("[", "]")):
        if body.count(a) != body.count(b):
            fail(f"{f.name}: {a}{b} 不配平 ({body.count(a)}/{body.count(b)})")
if ok:
    good("全部配平")

print("\n=== 4. 关键配置 ===")
bids = set(re.findall(r"PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);", t))
print("  bundle id:", bids)
if len(bids) == 1:
    good("Debug/Release 一致")
else:
    fail("bundle id 不一致")
for kw in ("UILaunchScreen_Generation", "SWIFT_VERSION = 5.0", "IPHONEOS_DEPLOYMENT_TARGET = 17.0",
           "ITSAppUsesNonExemptEncryption"):
    (good if kw in t else fail)(f"{'含' if kw in t else '缺'} {kw}")

print("\n=== 5. 无网络 / 无 SDK / 无内购 ===")
banned = ["URLSession", "NSURLConnection", "WKWebView", "import Alamofire", "import Firebase",
          "import StoreKit", "AppTrackingTransparency", "ProcessInfo", "UITEST"]
hits = [f"{f.name}: {b}" for f in SRC.rglob("*.swift") for b in banned if b in f.read_text()]
if hits:
    fail("发现可疑引用 → " + "; ".join(hits))
else:
    good("无网络、无第三方 SDK、无内购、无调试后门")

print("\n=== 6. 图标 ===")
icon = SRC / "Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
try:
    from PIL import Image
    im = Image.open(icon)
    if im.size == (1024, 1024) and im.mode == "RGB":
        good(f"1024x1024 无 alpha ({icon.stat().st_size // 1024}KB)")
    else:
        fail(f"图标规格不对 {im.size} {im.mode}")
except Exception as e:
    fail(f"图标读取失败 {e}")

print("\n" + "=" * 36)
print("全部通过 ✅" if ok else "存在问题 ❌")
sys.exit(0 if ok else 1)
