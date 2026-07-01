local modpath = minetest.get_modpath("voxsoul_combat")
local C = dofile(modpath .. "/constants.lua")
local M = {}

function M.is_in_iframes(elapsed, duration)
    duration = duration or C.DODGE.duration
    return elapsed >= C.DODGE.iframes_start and elapsed <= C.DODGE.iframes_end
end

local function dodge_direction(player)
    local ctrl = player:get_player_control()
    local yaw = player:get_look_horizontal()
    local mx, mz = 0, 0
    if ctrl.up then
        mz = mz - 1
    end
    if ctrl.down then
        mz = mz + 1
    end
    if ctrl.left then
        mx = mx - 1
    end
    if ctrl.right then
        mx = mx + 1
    end
    if mx == 0 and mz == 0 then
        mz = -1
    end
    local len = math.sqrt(mx * mx + mz * mz)
    mx, mz = mx / len, mz / len
    local sin_yaw = math.sin(yaw)
    local cos_yaw = math.cos(yaw)
    return {
        x = mx * cos_yaw - mz * sin_yaw,
        y = 0,
        z = mx * sin_yaw + mz * cos_yaw,
    }
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
    local dir = dodge_direction(player)
    local speed = 9
    player:set_velocity({ x = dir.x * speed, y = 1.5, z = dir.z * speed })
    return true
end

return M
