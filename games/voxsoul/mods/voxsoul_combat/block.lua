local modpath = minetest.get_modpath("voxsoul_combat")
local C = dofile(modpath .. "/constants.lua")

function voxsoul.combat.start_block(player)
    local data = voxsoul.combat.ensure_data(player)
    if data.state == "idle" or data.state == "blocking" then
        data.state = "blocking"
        data.blocking = true
        data.block_release_time = nil
    end
end

function voxsoul.combat.stop_block(player)
    local data = voxsoul.combat.ensure_data(player)
    if data.blocking then
        data.block_release_time = minetest.get_gametime()
        data.blocking = false
        if data.state == "blocking" then
            data.state = "idle"
        end
    end
end

function voxsoul.combat.try_parry(player, incoming_hit_time)
    local data = voxsoul.combat.ensure_data(player)
    if not data.block_release_time then
        return false
    end
    local delta = incoming_hit_time - data.block_release_time
    if delta >= 0 and delta <= C.PARRY.window then
        data.stamina = math.min(data.max_stamina, data.stamina + C.PARRY.stamina_restore)
        data.block_release_time = nil
        return true
    end
    data.stamina = math.max(0, data.stamina - C.STAMINA_COST.parry_fail)
    return false
end

function voxsoul.combat.apply_block_damage(player, damage)
    local data = voxsoul.combat.ensure_data(player)
    local stamina_cost = damage * 0.6
    data.stamina = data.stamina - stamina_cost
    if data.stamina <= 0 then
        voxsoul.combat.state.force_state(data, "guardbreak")
        data.guardbreak_timer = 1.0
        return damage
    end
    return damage * 0.2
end
