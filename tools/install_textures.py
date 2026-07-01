"""Install CC0 drummyfish Minetest textures into VoxSoul mod folders."""
from __future__ import annotations

import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "tools" / "minetest_textures"
MODS = ROOT / "games" / "voxsoul" / "mods"

MAPPING = {
    "voxsoul_world/textures/voxsoul_stone.png": "default_stone.png",
    "voxsoul_world/textures/voxsoul_grass.png": "default_grass.png",
    "voxsoul_world/textures/voxsoul_brick.png": "default_stone_brick.png",
    "voxsoul_world/textures/voxsoul_dark.png": "default_obsidian_brick.png",
    "voxsoul_world/textures/voxsoul_gold.png": "default_gold_block.png",
    "voxsoul_world/textures/voxsoul_water.png": "default_water.png",
    "voxsoul_world/textures/voxsoul_tutorial.png": "default_sign.png",
    "voxsoul_world/textures/voxsoul_enemy.png": "default_tool_bronzesword.png",
    "voxsoul_world/textures/voxsoul_rune.png": "default_mese_crystal.png",
    "voxsoul_boss/textures/voxsoul_boss.png": "default_mese_block.png",
    "voxsoul_entity/textures/voxsoul_placeholder.png": "default_steel_block.png",
    "voxsoul_grace/textures/voxsoul_grace.png": "default_meselamp.png",
}


def main() -> None:
    if not SRC.is_dir():
        raise SystemExit(f"Missing extracted textures at {SRC}")

    for dest_rel, src_name in MAPPING.items():
        src = SRC / src_name
        dest = MODS / dest_rel
        if not src.is_file():
            raise SystemExit(f"Missing source texture: {src}")
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dest)
        print("installed", dest_rel, "<-", src_name)


if __name__ == "__main__":
    main()
