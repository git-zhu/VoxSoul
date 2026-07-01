return {
    id = "tree_sentinel",
    name = "Tree Sentinel",
    sprite = "voxsoul_boss_tree_sentinel.png",
    visual_size = { x = 2.5, y = 3.5 },
    max_hp = 800,
    max_poise = 120,
    runes = 800,
    drop = { talisman = "golden_blessing" },
    phases = {
        { threshold = 1.0, attacks = { halberd_sweep = 1, shield_bash = 1, horse_stomp = 1 } },
    },
    attacks = {
        halberd_sweep = { windup = 1.2, damage = 45, poise = 30, hitbox = { type = "arc", radius = 4, angle = 120 } },
        shield_bash = { windup = 0.8, damage = 35, poise = 20, hitbox = { type = "arc", radius = 2.5, angle = 90 } },
        horse_stomp = { windup = 1.5, damage = 50, poise = 35, hitbox = { type = "circle", radius = 3.5 } },
    },
}
