from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1] / "games" / "voxsoul" / "mods"
COLORS = {
    "voxsoul_world/textures/voxsoul_stone.png": (120, 118, 110),
    "voxsoul_world/textures/voxsoul_grass.png": (70, 130, 55),
    "voxsoul_world/textures/voxsoul_brick.png": (150, 80, 60),
    "voxsoul_world/textures/voxsoul_dark.png": (45, 42, 50),
    "voxsoul_world/textures/voxsoul_gold.png": (200, 170, 60),
    "voxsoul_world/textures/voxsoul_water.png": (40, 90, 160),
    "voxsoul_world/textures/voxsoul_tutorial.png": (220, 200, 80),
    "voxsoul_world/textures/voxsoul_enemy.png": (180, 50, 50),
    "voxsoul_world/textures/voxsoul_rune.png": (255, 200, 50),
    "voxsoul_boss/textures/voxsoul_boss.png": (100, 30, 120),
    "voxsoul_entity/textures/voxsoul_placeholder.png": (200, 200, 200),
    "voxsoul_grace/textures/voxsoul_grace.png": (180, 220, 255),
}

for rel, rgb in COLORS.items():
    path = ROOT / rel
    path.parent.mkdir(parents=True, exist_ok=True)
    Image.new("RGB", (16, 16), rgb).save(path)
    print("wrote", rel)
