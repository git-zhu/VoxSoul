voxsoul.core = voxsoul.core or {}

-- Luanti 5.16 physics_overrides_v2: always send a complete override table so
-- partial updates from different mods do not zero out walk speed.
voxsoul.core.DEFAULT_PHYSICS = {
    speed = 1.0,
    speed_walk = 1.0,
    speed_climb = 1.0,
    speed_crouch = 1.0,
    speed_fast = 1.0,
    jump = 1.0,
    gravity = 1.0,
    liquid_fluidity = 1.0,
    liquid_fluidity_smooth = 1.0,
    liquid_sink = 1.0,
    acceleration_default = 1.0,
    acceleration_air = 1.0,
    acceleration_fast = 1.0,
    sneak = true,
    sneak_glitch = false,
    new_move = true,
}

function voxsoul.core.apply_physics(player, patch)
    if not player or not player.set_physics_override then
        return
    end
    local merged = {}
    for key, value in pairs(voxsoul.core.DEFAULT_PHYSICS) do
        merged[key] = value
    end
    if patch then
        for key, value in pairs(patch) do
            merged[key] = value
        end
    end
    player:set_physics_override(merged)
end

return voxsoul.core
