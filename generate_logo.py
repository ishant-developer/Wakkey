import os
import math
from PIL import Image, ImageDraw

def create_logo(size=512):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    center = size // 2
    radius = int(size * 0.44)

    # 1. Background rounded base (Squircle / Rounded Box)
    corner_r = int(size * 0.22)
    # Gradient-like background
    for r in range(radius, 0, -2):
        ratio = r / radius
        # Deep obsidian to midnight blue
        r_c = int(10 + 15 * (1 - ratio))
        g_c = int(14 + 30 * (1 - ratio))
        b_c = int(28 + 60 * (1 - ratio))
        draw.rounded_rectangle([center - r, center - r, center + r, center + r], radius=int(corner_r * ratio), fill=(r_c, g_c, b_c, 255))

    # 2. Concentric glowing rings
    ring_radius_1 = int(size * 0.32)
    ring_radius_2 = int(size * 0.25)

    draw.ellipse([center - ring_radius_1, center - ring_radius_1, center + ring_radius_1, center + ring_radius_1], outline=(33, 150, 243, 60), width=int(size * 0.035))
    draw.ellipse([center - ring_radius_2, center - ring_radius_2, center + ring_radius_2, center + ring_radius_2], outline=(33, 150, 243, 140), width=int(size * 0.025))

    # 3. Main Alarm Clock Body
    clock_r = int(size * 0.18)
    # Alarm bells on top
    bell_dist = int(clock_r * 0.95)
    bell_r = int(clock_r * 0.32)

    # Left bell
    ang_l = -math.pi * 0.75
    bx_l = center + int(bell_dist * math.cos(ang_l))
    by_l = center + int(bell_dist * math.sin(ang_l))
    draw.ellipse([bx_l - bell_r, by_l - bell_r, bx_l + bell_r, by_l + bell_r], fill=(41, 128, 250, 255))

    # Right bell
    ang_r = -math.pi * 0.25
    bx_r = center + int(bell_dist * math.cos(ang_r))
    by_r = center + int(bell_dist * math.sin(ang_r))
    draw.ellipse([bx_r - bell_r, by_r - bell_r, bx_r + bell_r, by_r + bell_r], fill=(41, 128, 250, 255))

    # Little hammer on top
    draw.rectangle([center - int(size * 0.015), center - int(clock_r * 1.25), center + int(size * 0.015), center - int(clock_r * 0.95)], fill=(200, 230, 255, 255))

    # Little legs at bottom
    leg_len = int(clock_r * 0.35)
    draw.line([center - int(clock_r * 0.6), center + int(clock_r * 0.7), center - int(clock_r * 0.8), center + int(clock_r * 0.7) + leg_len], fill=(41, 128, 250, 255), width=int(size * 0.02))
    draw.line([center + int(clock_r * 0.6), center + int(clock_r * 0.7), center + int(clock_r * 0.8), center + int(clock_r * 0.7) + leg_len], fill=(41, 128, 250, 255), width=int(size * 0.02))

    # Clock circle body
    draw.ellipse([center - clock_r, center - clock_r, center + clock_r, center + clock_r], fill=(25, 118, 210, 255), outline=(255, 255, 255, 230), width=int(size * 0.025))

    # Clock Face (White dial)
    face_r = int(clock_r * 0.82)
    draw.ellipse([center - face_r, center - face_r, center + face_r, center + face_r], fill=(245, 248, 255, 255))

    # Center dot
    dot_r = int(size * 0.02)
    draw.ellipse([center - dot_r, center - dot_r, center + dot_r, center + dot_r], fill=(20, 30, 50, 255))

    # Clock Hands (pointing at 6:00 - morning wake up!)
    # Hour hand pointing down to 6
    draw.line([center, center, center, center + int(face_r * 0.58)], fill=(30, 40, 70, 255), width=int(size * 0.022))
    # Minute hand pointing straight up to 12
    draw.line([center, center, center, center - int(face_r * 0.75)], fill=(41, 128, 250, 255), width=int(size * 0.016))

    return img

os.makedirs("assets/images", exist_ok=True)
logo = create_logo(512)
logo.save("assets/images/app_logo.png")

# Android mipmaps
sizes = {
    "android/app/src/main/res/mipmap-mdpi/ic_launcher.png": 48,
    "android/app/src/main/res/mipmap-hdpi/ic_launcher.png": 72,
    "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png": 96,
    "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png": 144,
    "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png": 192,
}

for path, sz in sizes.items():
    resized = logo.resize((sz, sz), Image.Resampling.LANCZOS)
    resized.save(path)
    print(f"Saved {path} ({sz}x{sz})")

print("All icons generated successfully.")
