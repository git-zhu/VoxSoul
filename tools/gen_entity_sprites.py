"""Generate distinct enemy/boss sprite textures for VoxSoul."""

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1] / "games" / "voxsoul" / "mods"


def save_sprite(rel: str, draw_fn) -> None:
    path = ROOT / rel
    path.parent.mkdir(parents=True, exist_ok=True)
    img = Image.new("RGBA", (32, 48), (0, 0, 0, 0))
    draw_fn(ImageDraw.Draw(img), 32, 48)
    img.save(path)
    print("wrote", rel)


def knight(draw, w, h) -> None:
    # armored knight silhouette — steel + red cape
    draw.rectangle((10, 8, 21, 14), fill=(180, 185, 195, 255))
    draw.rectangle((11, 14, 20, 34), fill=(120, 125, 135, 255))
    draw.rectangle((8, 16, 10, 28), fill=(100, 105, 115, 255))
    draw.rectangle((21, 16, 23, 28), fill=(100, 105, 115, 255))
    draw.polygon([(6, 18), (4, 30), (8, 30)], fill=(160, 40, 40, 255))
    draw.rectangle((12, 34, 19, 44), fill=(80, 85, 95, 255))
    draw.line((22, 20, 28, 36), fill=(200, 200, 210, 255), width=2)


def omen_freak(draw, w, h) -> None:
    # hunched omen — dark flesh + horn
    draw.ellipse((9, 10, 22, 22), fill=(60, 45, 50, 255))
    draw.polygon([(14, 6), (16, 2), (18, 8)], fill=(90, 70, 75, 255))
    draw.rectangle((10, 20, 21, 36), fill=(50, 35, 40, 255))
    draw.rectangle((7, 22, 9, 32), fill=(45, 30, 35, 255))
    draw.rectangle((22, 22, 24, 32), fill=(45, 30, 35, 255))
    draw.rectangle((11, 36, 20, 44), fill=(40, 28, 32, 255))


def tree_sentinel(draw, w, h) -> None:
    # golden armor on horseback silhouette
    draw.rectangle((4, 28, 27, 34), fill=(60, 45, 30, 255))
    draw.rectangle((10, 6, 21, 14), fill=(210, 175, 60, 255))
    draw.rectangle((11, 14, 20, 28), fill=(180, 145, 45, 255))
    draw.rectangle((8, 16, 10, 26), fill=(160, 130, 40, 255))
    draw.rectangle((21, 16, 23, 26), fill=(160, 130, 40, 255))
    draw.line((24, 18, 30, 8), fill=(190, 190, 200, 255), width=2)
    draw.rectangle((12, 34, 19, 42), fill=(140, 110, 35, 255))


def margit(draw, w, h) -> None:
    # tall horned boss — purple-grey
    draw.polygon([(10, 4), (8, 12), (12, 10)], fill=(120, 100, 130, 255))
    draw.polygon([(21, 4), (23, 12), (19, 10)], fill=(120, 100, 130, 255))
    draw.rectangle((10, 10, 21, 18), fill=(90, 75, 100, 255))
    draw.rectangle((11, 18, 20, 38), fill=(70, 58, 85, 255))
    draw.line((6, 22, 2, 34), fill=(180, 170, 190, 255), width=2)
    draw.rectangle((12, 38, 19, 46), fill=(55, 45, 70, 255))


def grafted_hag(draw, w, h) -> None:
    # bloated grafted body
    draw.ellipse((8, 12, 23, 28), fill=(100, 70, 75, 255))
    draw.ellipse((6, 22, 14, 32), fill=(80, 55, 60, 255))
    draw.ellipse((18, 24, 26, 34), fill=(75, 50, 55, 255))
    draw.rectangle((11, 30, 20, 42), fill=(85, 58, 62, 255))
    draw.ellipse((12, 8, 19, 14), fill=(110, 80, 85, 255))


def rune_pile(draw, w, h) -> None:
    draw.ellipse((8, 20, 24, 36), fill=(255, 200, 50, 255))
    draw.ellipse((10, 22, 22, 34), fill=(220, 160, 30, 255))
    draw.text((13, 24), "R", fill=(80, 50, 10, 255))


save_sprite("voxsoul_world/textures/voxsoul_enemy_knight.png", knight)
save_sprite("voxsoul_world/textures/voxsoul_enemy_omen.png", omen_freak)
save_sprite("voxsoul_world/textures/voxsoul_rune.png", rune_pile)
save_sprite("voxsoul_boss/textures/voxsoul_boss_tree_sentinel.png", tree_sentinel)
save_sprite("voxsoul_boss/textures/voxsoul_boss_margit.png", margit)
save_sprite("voxsoul_boss/textures/voxsoul_boss_grafted_hag.png", grafted_hag)
# legacy fallback
save_sprite("voxsoul_world/textures/voxsoul_enemy.png", knight)
save_sprite("voxsoul_boss/textures/voxsoul_boss.png", tree_sentinel)
