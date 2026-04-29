#!/usr/bin/env python3
"""Tortio feature graphic for Google Play (1024x500)."""
from PIL import Image, ImageDraw, ImageFont

W, H = 1024, 500
PRIMARY = (255, 107, 138)
SECONDARY = (255, 142, 83)
WHITE = (255, 255, 255, 255)

# Gradient
img = Image.new('RGB', (W, H), PRIMARY)
px = img.load()
for y in range(H):
    for x in range(W):
        t = (x + y * 0.6) / (W + H * 0.6)
        r = int(PRIMARY[0] + (SECONDARY[0] - PRIMARY[0]) * t)
        g = int(PRIMARY[1] + (SECONDARY[1] - PRIMARY[1]) * t)
        b = int(PRIMARY[2] + (SECONDARY[2] - PRIMARY[2]) * t)
        px[x, y] = (r, g, b)

d = ImageDraw.Draw(img, 'RGBA')

# Big "Tortio" text on left
font_path = '/usr/share/fonts/truetype/dejavu/DejaVuSerif-Bold.ttf'
title_font = ImageFont.truetype(font_path, 130)
sub_font = ImageFont.truetype(
    '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 32
)

title = 'Tortio'
sub = 'Recipe scaling for cake makers'

# Title position
title_x = 80
title_y = 150
d.text((title_x, title_y), title, font=title_font, fill=WHITE)

# Subtitle below
d.text((title_x, title_y + 165), sub, font=sub_font, fill=(255, 255, 255, 220))

# Mini cake icon on right (similar to app icon, scaled down)
cake_cx = 820
cake_base_y = 420

def rounded(xy, r, fill):
    d.rounded_rectangle(xy, radius=r, fill=fill)

# Plate shadow
d.ellipse((cake_cx - 200, cake_base_y - 12, cake_cx + 200, cake_base_y + 28), fill=(0, 0, 0, 50))

# Bottom layer
bw, bh = 320, 100
rounded((cake_cx - bw // 2, cake_base_y - bh, cake_cx + bw // 2, cake_base_y), 14, WHITE)

# Frosting drip
drip_y = cake_base_y - bh + 14
bumps = 6
drip_pts = []
for i in range(bumps + 1):
    x = cake_cx - bw // 2 + i * bw / bumps
    y = drip_y + (10 if i % 2 == 0 else -4)
    drip_pts.append((x, y))
poly = [(cake_cx - bw // 2, cake_base_y - bh)] + drip_pts + [(cake_cx + bw // 2, cake_base_y - bh)]
d.polygon(poly, fill=(255, 230, 240, 255))

# Middle
mw, mh = 230, 80
my = cake_base_y - bh - 6
rounded((cake_cx - mw // 2, my - mh, cake_cx + mw // 2, my), 12, WHITE)

# Top
tw, th = 140, 60
ty = my - mh - 6
rounded((cake_cx - tw // 2, ty - th, cake_cx + tw // 2, ty), 10, WHITE)

# Candle
cw, ch = 14, 60
cx0 = cake_cx - cw // 2
cy0 = ty - th - ch - 6
rounded((cx0, cy0, cx0 + cw, cy0 + ch), 5, WHITE)

# Flame
fcx = cake_cx
fcy = cy0 - 22
d.ellipse((fcx - 14, fcy - 22, fcx + 14, fcy + 14), fill=(255, 230, 100, 255))
d.ellipse((fcx - 7, fcy - 14, fcx + 7, fcy + 6), fill=(255, 180, 60, 255))

img.save('/tmp/tortio-feature-1024x500.png', 'PNG', optimize=True)
print('done')
