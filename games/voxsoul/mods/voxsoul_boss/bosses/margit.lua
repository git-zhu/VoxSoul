return {
    id = "margit",
    name = "Margit",
    max_hp = 1200,
    max_poise = 80,
    runes = 3000,
    drop = { weapon = "curved_sword" },
    phases = {
        { threshold = 1.0, attacks = { cane_sweep = 1, tail_swipe = 1, jump_slash = 1, light_blade = 1 } },
        { threshold = 0.5, name_suffix = " - Omen Form", attacks = { cane_sweep = 1, triple_blade = 2, rain_slam = 1, light_blade = 1 } },
    },
    attacks = {
        cane_sweep = { windup = 0.6, damage = 30, poise = 15, hitbox = { type = "arc", radius = 3, angle = 100 } },
        tail_swipe = { windup = 1.0, damage = 40, poise = 25, hitbox = { type = "arc", radius = 3, angle = 180 } },
        jump_slash = { windup = 1.4, damage = 55, poise = 40, hitbox = { type = "circle", radius = 3 } },
        light_blade = { windup = 0.5, damage = 25, poise = 10, hitbox = { type = "arc", radius = 8, angle = 30 } },
        triple_blade = { windup = 0.4, damage = 20, poise = 8, hitbox = { type = "arc", radius = 10, angle = 20 }, repeat_count = 3 },
        rain_slam = { windup = 2.0, damage = 60, poise = 40, hitbox = { type = "circle", radius = 6 } },
    },
}
