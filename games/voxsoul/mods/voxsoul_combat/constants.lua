return {
    STAMINA_REGEN_RATE = 35,
    STAMINA_REGEN_DELAY_ATTACK = 0.8,
    STAMINA_REGEN_DELAY_DODGE = 1.0,
    STAMINA_EXHAUST_THRESHOLD = 0.20,
    STAMINA_COST = {
        light_attack = 12,
        heavy_attack = 28,
        dodge = 22,
        dodge_chain_bonus = 5,
        block_per_sec = 8,
        parry_fail = 15,
    },
    ATTACK = {
        light = { base_damage = 35, windup = 0.3, poise = 8, recovery = 0.3 },
        heavy = { base_damage = 70, windup = 0.7, poise = 25, recovery = 0.4 },
    },
    DODGE = { duration = 0.6, iframes_start = 0.1, iframes_end = 0.5, cost = 22 },
    PARRY = { window = 0.25, stagger = 2.0, stamina_restore = 30 },
    POISE_RECOVER_RATE = 0.05,
    LOCKON_RANGE = 15,
    LOCKON_BREAK_RANGE = 20,
}
