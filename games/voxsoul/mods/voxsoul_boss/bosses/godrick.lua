return {
    id = "godrick",
    name = "接肢葛瑞克",
    sprite = "voxsoul_boss_godrick.png",
    visual_size = { x = 2.4, y = 3.6 },
    max_hp = 1800,
    max_poise = 100,
    runes = 5000,
    phase_message = "见证吧！接肢的艺术！",
    phases = {
        {
            threshold = 1.0,
            attacks = { axe_sweep = 1, wind_gust = 1, leap_slam = 1, kneel_shock = 1 },
        },
        {
            threshold = 0.5,
            name_suffix = " — 龙焰形态",
            attacks = { fire_sweep = 2, fire_slam = 1, striding_flame = 1, axe_sweep = 1 },
        },
    },
    attacks = {
        axe_sweep = { windup = 0.8, damage = 38, poise = 18, hitbox = { type = "arc", radius = 3.5, angle = 100 } },
        wind_gust = { windup = 1.0, damage = 28, poise = 12, hitbox = { type = "arc", radius = 4, angle = 120 } },
        leap_slam = { windup = 1.3, damage = 52, poise = 30, hitbox = { type = "circle", radius = 3 } },
        kneel_shock = { windup = 1.5, damage = 45, poise = 25, hitbox = { type = "circle", radius = 4 } },
        fire_sweep = { windup = 1.2, damage = 42, poise = 22, hitbox = { type = "arc", radius = 5, angle = 90 } },
        fire_slam = { windup = 1.0, damage = 48, poise = 28, hitbox = { type = "circle", radius = 3.5 } },
        striding_flame = { windup = 1.4, damage = 35, poise = 15, hitbox = { type = "arc", radius = 6, angle = 45 } },
    },
}
