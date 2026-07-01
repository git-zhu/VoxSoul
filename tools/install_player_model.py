"""Install VoxSoul player mesh and CC0 knight/tarnished skin."""
from __future__ import annotations

import shutil
import urllib.request
import zipfile
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MOD = ROOT / "games" / "voxsoul" / "mods" / "voxsoul_player"
SKINS_ZIP = ROOT / "tools" / "minetest_skins_pack_1.zip"
SKINS_DIR = ROOT / "tools" / "minetest_skins_pack_1" / "Minetest Skins Pack 1"
SKINS_URL = "https://opengameart.org/sites/default/files/minetest_skins_pack_1.zip"
MODEL_URL = "https://raw.githubusercontent.com/minetest-game/player_api/master/models/character.b3d"
# Full grey plate helm with visor slits; CC0 knight look from this pack.
KNIGHT_SKIN = "Skin_27.png"


def ensure_knight_skin() -> Path:
    skin = SKINS_DIR / KNIGHT_SKIN
    if not skin.is_file():
        if not SKINS_ZIP.is_file():
            print("downloading CC0 skins pack...")
            urllib.request.urlretrieve(SKINS_URL, SKINS_ZIP)
        SKINS_DIR.parent.mkdir(parents=True, exist_ok=True)
        with zipfile.ZipFile(SKINS_ZIP) as archive:
            archive.extractall(SKINS_DIR.parent)
    if not skin.is_file():
        raise SystemExit(f"Missing knight skin source: {skin}")
    return skin


def export_knight_skin(src: Path, dest: Path) -> None:
    image = Image.open(src).convert("RGBA")
    if image.size != (128, 64):
        image = image.resize((128, 64), Image.NEAREST)
    dest.parent.mkdir(parents=True, exist_ok=True)
    image.save(dest)


def main() -> None:
    (MOD / "models").mkdir(parents=True, exist_ok=True)

    model_dest = MOD / "models" / "voxsoul_tarnished.b3d"
    urllib.request.urlretrieve(MODEL_URL, model_dest)
    print("installed", model_dest.relative_to(ROOT))

    skin_dest = MOD / "textures" / "voxsoul_tarnished.png"
    export_knight_skin(ensure_knight_skin(), skin_dest)
    print("installed", skin_dest.relative_to(ROOT), "<-", KNIGHT_SKIN)


if __name__ == "__main__":
    main()
