local modpath = minetest.get_modpath("voxsoul_combat")
local C = dofile(modpath .. "/constants.lua")

local lock_targets = {}

local function find_nearest_enemy(player)
    local pos = player:get_pos()
    local best
    local best_dist = C.LOCKON_RANGE
    for _, obj in ipairs(minetest.get_objects_inside_radius(pos, C.LOCKON_RANGE)) do
        if not obj:is_player() then
            local ent = obj:get_luaentity()
            if ent and ent.voxsoul_combatant then
                local dist = vector.distance(pos, obj:get_pos())
                if dist < best_dist then
                    best = obj
                    best_dist = dist
                end
            end
        end
    end
    return best
end

function voxsoul.combat.toggle_lockon(player)
    local name = player:get_player_name()
    local current = lock_targets[name]
    if current and current:get_luaentity() then
        lock_targets[name] = nil
        return
    end
    lock_targets[name] = find_nearest_enemy(player)
end

function voxsoul.combat.get_lock_target(player)
    local name = player:get_player_name()
    local obj = lock_targets[name]
    if not obj or not obj:get_luaentity() then
        lock_targets[name] = nil
        return nil
    end
    if vector.distance(player:get_pos(), obj:get_pos()) > C.LOCKON_BREAK_RANGE then
        lock_targets[name] = nil
        return nil
    end
    return obj
end

function voxsoul.combat.clear_lockon(player)
    lock_targets[player:get_player_name()] = nil
end
