return {
    id = "grafted_hag",
    name = "Grafted Hag",
    sprite = "voxsoul_boss_grafted_hag.png",
    visual_size = { x = 2.0, y = 2.5 },
    max_hp = 600,
    max_poise = 50,
    runes = 1500,
    phases = {
        { threshold = 1.0, attacks = { claw = 1, roll_crush = 1, spit = 1 } },
    },
    attacks = {
        claw = { windup = 0.5, damage = 25, poise = 12, hitbox = { type = "arc", radius = 2, angle = 90 } },
        roll_crush = { windup = 1.0, damage = 40, poise = 25, hitbox = { type = "arc", radius = 4, angle = 60 } },
        spit = { windup = 1.8, damage = 35, poise = 20, hitbox = { type = "arc", radius = 5, angle = 45 } },
    },
}
