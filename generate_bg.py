from PIL import Image, ImageDraw
import math

def create_mountain_bg(width=1080, height=1920):
    img = Image.new("RGB", (width, height))
    draw = ImageDraw.Draw(img)

    # Sky gradient: dark twilight blue to dusk pink/amber
    for y in range(height):
        ratio = y / height
        if ratio < 0.5:
            # Deep night sky to twilight indigo
            r = int(12 + 15 * (ratio / 0.5))
            g = int(18 + 25 * (ratio / 0.5))
            b = int(35 + 40 * (ratio / 0.5))
        elif ratio < 0.7:
            # Twilight indigo to mountain dusk glow
            sub = (ratio - 0.5) / 0.2
            r = int(27 + 45 * sub)
            g = int(43 + 30 * sub)
            b = int(75 + 10 * sub)
        else:
            # Dark lake reflection
            sub = (ratio - 0.7) / 0.3
            r = int(15 + 10 * (1 - sub))
            g = int(22 + 12 * (1 - sub))
            b = int(38 + 20 * (1 - sub))
        draw.line([(0, y), (width, y)], fill=(r, g, b))

    # Distant peaks
    peaks_back = [
        (0, 1150), (200, 950), (350, 1080), (540, 840),
        (750, 1050), (900, 920), (width, 1150), (width, height), (0, height)
    ]
    draw.polygon(peaks_back, fill=(20, 32, 54))

    # Foreground peaks
    peaks_front = [
        (0, 1280), (180, 1080), (380, 1220), (540, 960),
        (720, 1180), (920, 1040), (width, 1280), (width, height), (0, height)
    ]
    draw.polygon(peaks_front, fill=(12, 19, 34))

    # Lake line
    draw.rectangle([0, 1320, width, height], fill=(9, 14, 25))

    return img

bg = create_mountain_bg()
bg.save("assets/images/mountain_bg.png")
print("Saved assets/images/mountain_bg.png")
