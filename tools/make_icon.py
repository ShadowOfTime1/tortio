#!/usr/bin/env python3
"""Generate Tortio app icons:
- Legacy launcher PNG (mipmap-*/ic_launcher.png) — gradient + cake, для < API 26.
- Adaptive icon foreground (mipmap-*/ic_launcher_foreground.png) — cake on
  transparent bg, scaled to 66% safe zone (108dp canvas, 66dp content).
- Background color и XML wiring добавлены в репо вручную, см.
  android/app/src/main/res/values/ic_launcher_background.xml и
  mipmap-anydpi-v26/ic_launcher.xml.
- 1024×1024 мастер + Play 512×512 promo.
"""
from PIL import Image, ImageDraw

SIZE = 1024
PRIMARY = (255, 107, 138)   # #FF6B8A
SECONDARY = (255, 142, 83)  # #FF8E53
WHITE = (255, 255, 255, 255)
SHADOW = (0, 0, 0, 60)

# Адаптивная иконка: 108dp canvas, 66dp safe zone для всех масок (круг,
# squircle, teardrop). Контент = 66/108 ≈ 0.611 от canvas.
SAFE_ZONE_RATIO = 0.61


def gradient(size):
    """Linear gradient pink→orange diagonal."""
    img = Image.new('RGB', (size, size), PRIMARY)
    px = img.load()
    for y in range(size):
        for x in range(size):
            t = (x + y) / (2 * size)
            r = int(PRIMARY[0] + (SECONDARY[0] - PRIMARY[0]) * t)
            g = int(PRIMARY[1] + (SECONDARY[1] - PRIMARY[1]) * t)
            b = int(PRIMARY[2] + (SECONDARY[2] - PRIMARY[2]) * t)
            px[x, y] = (r, g, b)
    return img


def rounded_rect(draw, xy, radius, fill, outline=None, width=1):
    """Rounded rectangle wrapper for Pillow compat."""
    draw.rounded_rectangle(xy, radius=radius, fill=fill, outline=outline, width=width)


def draw_cake(img):
    """Draw a stylized layered cake centered on image."""
    d = ImageDraw.Draw(img, 'RGBA')
    cx = SIZE // 2

    # Plate (subtle ellipse base, dark shadow under cake)
    d.ellipse((180, 770, SIZE - 180, 830), fill=(0, 0, 0, 50))

    # Bottom layer (largest)
    bot_w = 620
    bot_h = 220
    bot_y0 = 540
    rounded_rect(
        d,
        (cx - bot_w // 2, bot_y0, cx + bot_w // 2, bot_y0 + bot_h),
        radius=24,
        fill=WHITE,
    )

    # Frosting drip (wavy line on top of bottom layer)
    drip_y = bot_y0 + 32
    drip_pts = []
    drip_w = bot_w
    drip_x_start = cx - drip_w // 2
    bumps = 8
    for i in range(bumps + 1):
        x = drip_x_start + i * drip_w / bumps
        y = drip_y + (20 if i % 2 == 0 else -8)
        drip_pts.append((x, y))
    # Build a polygon under drip line down to bot_y0+bot_h
    poly = [(drip_x_start, bot_y0)] + drip_pts + [(drip_x_start + drip_w, bot_y0)]
    d.polygon(poly, fill=(255, 230, 240, 255))

    # Middle layer
    mid_w = 460
    mid_h = 180
    mid_y0 = bot_y0 - mid_h - 6
    rounded_rect(
        d,
        (cx - mid_w // 2, mid_y0, cx + mid_w // 2, mid_y0 + mid_h),
        radius=22,
        fill=WHITE,
    )

    # Top layer (smallest)
    top_w = 280
    top_h = 130
    top_y0 = mid_y0 - top_h - 6
    rounded_rect(
        d,
        (cx - top_w // 2, top_y0, cx + top_w // 2, top_y0 + top_h),
        radius=18,
        fill=WHITE,
    )

    # Candle (thin rectangle)
    candle_w = 24
    candle_h = 110
    candle_x0 = cx - candle_w // 2
    candle_y0 = top_y0 - candle_h - 6
    rounded_rect(
        d,
        (candle_x0, candle_y0, candle_x0 + candle_w, candle_y0 + candle_h),
        radius=8,
        fill=WHITE,
    )

    # Flame (teardrop / small ellipse on top of candle)
    flame_cx = cx
    flame_cy = candle_y0 - 38
    d.ellipse(
        (flame_cx - 22, flame_cy - 38, flame_cx + 22, flame_cy + 22),
        fill=(255, 230, 100, 255),
    )
    d.ellipse(
        (flame_cx - 12, flame_cy - 24, flame_cx + 12, flame_cy + 8),
        fill=(255, 180, 60, 255),
    )


def make_foreground_master():
    """Foreground = только торт на прозрачном фоне, scaled под safe zone.
    Возвращает 1024×1024 RGBA, где торт занимает центральные ~61%.
    """
    fg = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    # Рисуем торт как обычно (он сам центрируется в 1024×1024)
    draw_cake(fg)
    # Сжимаем содержимое до safe zone: подгоняем рисунок до (SIZE * 0.61)
    # и центрируем на новом 1024 canvas.
    inner_size = int(SIZE * SAFE_ZONE_RATIO)
    inner = fg.resize((inner_size, inner_size), Image.LANCZOS)
    out = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    offset = (SIZE - inner_size) // 2
    out.paste(inner, (offset, offset), inner)
    return out


def main():
    # === Legacy & promo ===
    master = gradient(SIZE)
    draw_cake(master)
    master.save('/tmp/tortio-icon-1024.png', 'PNG', optimize=True)

    play = master.resize((512, 512), Image.LANCZOS)
    play.save('/tmp/tortio-icon-play-512.png', 'PNG', optimize=True)

    # Android mipmap legacy (square gradient + cake) — для < API 26.
    sizes = {
        'mdpi': 48,
        'hdpi': 72,
        'xhdpi': 96,
        'xxhdpi': 144,
        'xxxhdpi': 192,
    }
    for name, size in sizes.items():
        out = master.resize((size, size), Image.LANCZOS)
        out.save(f'/tmp/ic_launcher_{name}.png', 'PNG', optimize=True)

    # === Adaptive icon foreground (API 26+) ===
    # Размеры canvas адаптивной иконки: 108dp = 1.5× legacy launcher size.
    fg_master = make_foreground_master()
    adaptive_sizes = {
        'mdpi': 108,
        'hdpi': 162,
        'xhdpi': 216,
        'xxhdpi': 324,
        'xxxhdpi': 432,
    }
    for name, size in adaptive_sizes.items():
        out = fg_master.resize((size, size), Image.LANCZOS)
        out.save(f'/tmp/ic_launcher_foreground_{name}.png', 'PNG', optimize=True)

    print('done')


if __name__ == '__main__':
    main()
