"""Generate Elden Ring–inspired HUD textures for VoxSoul."""

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1] / "games" / "voxsoul" / "mods" / "voxsoul_ui" / "textures"
ROOT.mkdir(parents=True, exist_ok=True)

# Palette — dark stone + gold trim + crimson / stamina green
STONE = (28, 24, 22)
STONE_EDGE = (18, 15, 14)
GOLD = (200, 170, 90)
GOLD_DIM = (120, 100, 55)
HP_FILL = (170, 35, 35)
HP_HIGH = (220, 70, 60)
HP_BG = (50, 18, 18)
ST_FILL = (120, 150, 55)
ST_HIGH = (170, 200, 80)
ST_BG = (30, 40, 18)
BOSS_FILL = (190, 45, 45)
BOSS_BG = (40, 15, 15)


def elden_half_icon(path: Path, fill: tuple, fill_hi: tuple, bg: tuple) -> None:
    """Statbar cell: dark frame, gold corners, gradient fill."""
    img = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.rectangle((0, 0, 15, 15), fill=STONE_EDGE + (255,))
    draw.rectangle((1, 1, 14, 14), fill=STONE + (255,))
    draw.rectangle((2, 2, 13, 13), fill=bg + (255,))
    # left half filled
    draw.rectangle((3, 4, 7, 11), fill=fill + (255,))
    draw.rectangle((3, 4, 6, 7), fill=fill_hi + (255,))
    # right half bg (empty segment look)
    draw.rectangle((8, 4, 12, 11), fill=bg + (255,))
    draw.point((2, 2), fill=GOLD + (255,))
    draw.point((13, 2), fill=GOLD_DIM + (255,))
    draw.point((2, 13), fill=GOLD_DIM + (255,))
    draw.point((13, 13), fill=GOLD + (255,))
    img.save(path)


def elden_half_bg(path: Path, bg: tuple) -> None:
    img = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.rectangle((0, 0, 15, 15), fill=STONE_EDGE + (255,))
    draw.rectangle((1, 1, 14, 14), fill=STONE + (255,))
    draw.rectangle((2, 2, 13, 13), fill=bg + (255,))
    draw.rectangle((3, 4, 12, 11), fill=bg + (255,))
    for x, y in ((2, 2), (13, 2), (2, 13), (13, 13)):
        draw.point((x, y), fill=GOLD_DIM + (200,))
    img.save(path)


def boss_half_icon(path: Path, fill: tuple, bg: tuple) -> None:
    img = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.rectangle((0, 0, 15, 15), fill=(10, 8, 8, 255))
    draw.rectangle((1, 3, 14, 12), fill=bg + (255,))
    draw.rectangle((2, 4, 7, 11), fill=fill + (255,))
    draw.rectangle((8, 4, 13, 11), fill=bg + (255,))
    draw.line((1, 2, 14, 2), fill=GOLD + (255,))
    draw.line((1, 13, 14, 13), fill=GOLD_DIM + (255,))
    img.save(path)


def lockon_ring(path: Path) -> None:
    img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.ellipse((2, 2, 29, 29), outline=(220, 50, 45, 220), width=2)
    draw.ellipse((6, 6, 25, 25), outline=(200, 170, 90, 120), width=1)
    img.save(path)


def flash_overlay(path: Path, rgba: tuple) -> None:
    img = Image.new("RGBA", (4, 4), rgba)
    img.save(path)


def gold_spark(path: Path) -> None:
    img = Image.new("RGBA", (8, 8), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.ellipse((1, 1, 6, 6), fill=(255, 220, 100, 255))
    draw.point((3, 3), fill=(255, 255, 220, 255))
    img.save(path)


elden_half_icon(ROOT / "voxsoul_hp.png", HP_FILL, HP_HIGH, HP_BG)
elden_half_bg(ROOT / "voxsoul_hp_bg.png", HP_BG)
elden_half_icon(ROOT / "voxsoul_stamina.png", ST_FILL, ST_HIGH, ST_BG)
elden_half_bg(ROOT / "voxsoul_stamina_bg.png", ST_BG)
boss_half_icon(ROOT / "voxsoul_boss_hp.png", BOSS_FILL, BOSS_BG)
elden_half_bg(ROOT / "voxsoul_boss_hp_bg.png", BOSS_BG)
lockon_ring(ROOT / "voxsoul_lockon.png")
flash_overlay(ROOT / "voxsoul_flash_red.png", (180, 30, 30, 100))
flash_overlay(ROOT / "voxsoul_flash_gold.png", (255, 200, 80, 120))
gold_spark(ROOT / "voxsoul_gold.png")

print("Elden UI textures written to", ROOT)
