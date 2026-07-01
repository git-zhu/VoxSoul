from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1] / "games" / "voxsoul" / "mods" / "voxsoul_ui" / "textures"
ROOT.mkdir(parents=True, exist_ok=True)


def half_icon(path: Path, fill: tuple[int, int, int], bg: tuple[int, int, int]) -> None:
    img = Image.new("RGBA", (16, 16), bg + (255,))
    draw = ImageDraw.Draw(img)
    draw.rectangle((1, 3, 7, 12), fill=fill + (255,))
    draw.rectangle((8, 3, 14, 12), fill=fill + (255,))
    img.save(path)


half_icon(ROOT / "voxsoul_hp.png", (200, 40, 40), (60, 20, 20))
half_icon(ROOT / "voxsoul_hp_bg.png", (80, 30, 30), (40, 15, 15))
half_icon(ROOT / "voxsoul_stamina.png", (40, 180, 60), (20, 60, 30))
half_icon(ROOT / "voxsoul_stamina_bg.png", (30, 80, 40), (15, 40, 20))

lock = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
draw = ImageDraw.Draw(lock)
draw.ellipse((2, 2, 13, 13), outline=(220, 40, 40, 255), width=2)
lock.save(ROOT / "voxsoul_lockon.png")
print("UI textures written to", ROOT)
