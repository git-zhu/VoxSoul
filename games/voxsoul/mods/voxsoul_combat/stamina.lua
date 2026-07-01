local modpath = minetest.get_modpath("voxsoul_combat")
local C = dofile(modpath .. "/constants.lua")
local M = {}

function M.can_spend(current, cost)
    return current >= cost
end

function M.is_exhausted(current, max_stamina)
    return current < max_stamina * C.STAMINA_EXHAUST_THRESHOLD
end

function M.tick(current, max_stamina, dt, regen_delay, allow_regen)
    if regen_delay > 0 then
        return current, regen_delay - dt
    end
    if not allow_regen then
        return current, 0
    end
    local next_val = math.min(max_stamina, current + C.STAMINA_REGEN_RATE * dt)
    return next_val, 0
end

return M
