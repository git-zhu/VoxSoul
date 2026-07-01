"""Generate Elden Ring–inspired HUD textures for VoxSoul."""

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1] / "games" / "voxsoul" / "mods" / "voxsoul_ui" / "textures"
ROOT.mkdir(parents=True, exist_ok=True)

# Palette — weathered stone frame + gold filigree + crimson / stamina green
STONE = (22, 18, 16)
STONE_EDGE = (12, 10, 9)
STONE_HI = (38, 32, 28)
GOLD = (212, 178, 88)
GOLD_DIM = (108, 88, 48)
GOLD_BRIGHT = (255, 228, 140)
HP_FILL = (158, 28, 28)
HP_HIGH = (210, 58, 48)
HP_BG = (42, 14, 14)
ST_FILL = (108, 138, 48)
ST_HIGH = (158, 188, 72)
ST_BG = (24, 34, 14)
BOSS_FILL = (178, 38, 38)
BOSS_BG = (34, 12, 12)


def elden_half_icon(path: Path, fill: tuple, fill_hi: tuple, bg: tuple) -> None:
    """Statbar cell: stone frame, gold trim, left-half fill for Luanti statbar."""
    img = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.rectangle((0, 0, 15, 15), fill=STONE_EDGE + (255,))
    draw.rectangle((1, 1, 14, 14), fill=STONE + (255,))
    draw.rectangle((2, 2, 13, 13), fill=STONE_HI + (255,))
    draw.rectangle((3, 3, 13, 13), fill=bg + (255,))
    draw.rectangle((3, 4, 7, 11), fill=fill + (255,))
    draw.rectangle((3, 4, 6, 8), fill=fill_hi + (255,))
    draw.rectangle((8, 4, 12, 11), fill=bg + (255,))
    draw.line((2, 2, 13, 2), fill=GOLD_DIM + (220,))
    draw.line((2, 13, 13, 13), fill=GOLD + (200,))
    draw.point((2, 2), fill=GOLD_BRIGHT + (255,))
    draw.point((13, 13), fill=GOLD + (255,))
    img.save(path)


def elden_half_bg(path: Path, bg: tuple) -> None:
    img = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.rectangle((0, 0, 15, 15), fill=STONE_EDGE + (255,))
    draw.rectangle((1, 1, 14, 14), fill=STONE + (255,))
    draw.rectangle((2, 2, 13, 13), fill=STONE_HI + (255,))
    draw.rectangle((3, 4, 12, 11), fill=bg + (255,))
    draw.line((2, 2, 13, 2), fill=GOLD_DIM + (180,))
    draw.line((2, 13, 13, 13), fill=GOLD_DIM + (140,))
    img.save(path)


def boss_half_icon(path: Path, fill: tuple, bg: tuple) -> None:
    img = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.rectangle((0, 0, 15, 15), fill=(8, 6, 6, 255))
    draw.rectangle((1, 2, 14, 13), fill=bg + (255,))
    draw.rectangle((2, 4, 7, 11), fill=fill + (255,))
    draw.rectangle((8, 4, 13, 11), fill=bg + (255,))
    draw.line((1, 1, 14, 1), fill=GOLD_BRIGHT + (255,))
    draw.line((1, 14, 14, 14), fill=GOLD_DIM + (255,))
    draw.point((1, 1), fill=GOLD + (255,))
    draw.point((14, 1), fill=GOLD + (255,))
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
