#!/usr/bin/env python3
"""生成 Apiary Log 的 1024x1024 图标（蜂蜜色 + 蜂巢六边形，无 alpha）。"""
import math
import pathlib

from PIL import Image, ImageDraw

S = 4096
OUT = 1024
DST = pathlib.Path("/home/xykj211/ApiaryLog/ApiaryLog/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png")

TOP = (245, 175, 45)
BOT = (196, 112, 12)
DARK = (74, 42, 8)

img = Image.new("RGB", (S, S), TOP)
d = ImageDraw.Draw(img)
# 渐变
for y in range(S):
    t = y / (S - 1)
    d.line([(0, y), (S, y)],
           fill=(int(TOP[0] + (BOT[0] - TOP[0]) * t),
                 int(TOP[1] + (BOT[1] - TOP[1]) * t),
                 int(TOP[2] + (BOT[2] - TOP[2]) * t)))


def hexagon(cx, cy, r, pointy_up=True):
    pts = []
    for i in range(6):
        ang = math.radians(60 * i + (90 if pointy_up else 60))
        pts.append((cx + r * math.cos(ang), cy - r * math.sin(ang)))
    return pts


# 蜂巢：中心一个实心，周围六个描边
cx, cy = S / 2, S / 2
r = S * 0.155
line = int(S * 0.030)

d.polygon(hexagon(cx, cy, r), fill=DARK)

for i in range(6):
    ang = math.radians(60 * i)
    ox = cx + 1.74 * r * math.cos(ang)
    oy = cy - 1.74 * r * math.sin(ang)
    d.polygon(hexagon(ox, oy, r), outline=DARK, width=line)

img = img.resize((OUT, OUT), Image.LANCZOS)
DST.parent.mkdir(parents=True, exist_ok=True)
img.save(DST, "PNG")
print("saved", DST, img.size, img.mode)
