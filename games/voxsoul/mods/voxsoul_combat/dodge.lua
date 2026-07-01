local modpath = minetest.get_modpath("voxsoul_combat")
local C = dofile(modpath .. "/constants.lua")
local M = {}

function M.is_in_iframes(elapsed, duration)
    duration = duration or C.DODGE.duration
    return elapsed >= C.DODGE.iframes_start and elapsed <= C.DODGE.iframes_end
end

function M.try_start(player, data)
    local cost = C.STAMINA_COST.dodge + (data.dodge_chain or 0) * C.STAMINA_COST.dodge_chain_bonus
    if voxsoul.player and voxsoul.player.get_dodge_cost then
        cost = voxsoul.player.get_dodge_cost(player, cost)
    end
    if not voxsoul.combat.stamina.can_spend(data.stamina, cost) then
        return false
    end
    if data.state ~= "idle" and data.state ~= "blocking" then
        return false
    end
    data.stamina = data.stamina - cost
    data.state = "dodging"
    data.dodge_elapsed = 0
    data.dodge_chain = math.min(2, (data.dodge_chain or 0) + 1)
    data.regen_delay = C.STAMINA_REGEN_DELAY_DODGE
    player:set_velocity({ x = 0, y = 0, z = 0 })
    return true
end

return M
