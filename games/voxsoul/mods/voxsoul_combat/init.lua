voxsoul.combat = {}
local modpath = minetest.get_modpath("voxsoul_combat")
voxsoul.combat.constants = dofile(modpath .. "/constants.lua")
voxsoul.combat.stamina = dofile(modpath .. "/stamina.lua")
voxsoul.combat.state = dofile(modpath .. "/state.lua")
voxsoul.combat.dodge = dofile(modpath .. "/dodge.lua")
dofile(modpath .. "/attacks.lua")
dofile(modpath .. "/block.lua")
dofile(modpath .. "/lockon.lua")

local player_data = {}

function voxsoul.combat.sync_engine_hp(player)
    local data = voxsoul.combat.ensure_data(player)
    local shown = math.max(1, math.min(20, math.ceil(20 * data.hp / data.max_hp)))
    player:set_hp(shown)
end

function voxsoul.combat.ensure_data(player)
    local name = player:get_player_name()
    if not player_data[name] then
        player_data[name] = {
            state = "idle",
            stamina = 100,
            max_stamina = 100,
            hp = 400,
            max_hp = 400,
            poise = 100,
            max_poise = 100,
            regen_delay = 0,
            dodge_elapsed = 0,
            dodge_chain = 0,
            blocking = false,
        }
    end
    return player_data[name]
end

function voxsoul.combat.is_invincible(player)
    local data = voxsoul.combat.ensure_data(player)
    if data.state ~= "dodging" then
        return false
    end
    return voxsoul.combat.dodge.is_in_iframes(data.dodge_elapsed)
end

function voxsoul.combat.refresh_stats(player)
    if not voxsoul.player then
        return
    end
    local data = voxsoul.combat.ensure_data(player)
    data.max_hp = voxsoul.player.get_max_hp(player)
    data.max_stamina = voxsoul.player.get_max_stamina(player)
    data.hp = math.min(data.hp, data.max_hp)
    data.stamina = math.min(data.stamina, data.max_stamina)
end

minetest.register_on_player_hpchange(function(player, hp_change)
    return true
end)

minetest.register_on_joinplayer(function(player)
    voxsoul.combat.ensure_data(player)
    minetest.after(0, function()
        if player:is_player() then
            voxsoul.combat.refresh_stats(player)
            voxsoul.combat.sync_engine_hp(player)
        end
    end)
end)

minetest.register_on_leaveplayer(function(player)
    player_data[player:get_player_name()] = nil
    voxsoul.combat.clear_lockon(player)
end)

minetest.register_on_punchplayer(function(player, hitter)
    if voxsoul.combat.is_invincible(player) then
        return true
    end
end)

minetest.register_globalstep(function(dt)
    for _, player in ipairs(minetest.get_connected_players()) do
        local data = voxsoul.combat.ensure_data(player)

        if data.state == "dodging" then
            data.dodge_elapsed = data.dodge_elapsed + dt
            if data.dodge_elapsed >= voxsoul.combat.constants.DODGE.duration then
                data.state = "idle"
                data.dodge_elapsed = 0
            end
        elseif (data.hitstop_timer or 0) > 0 then
            data.hitstop_timer = data.hitstop_timer - dt
        elseif data.state == "attacking" then
            data.attack_timer = (data.attack_timer or 0) + dt
            if data.pending_attack and data.attack_timer >= data.pending_attack.windup then
                voxsoul.combat.resolve_attack_hit(player, data.pending_attack)
                data.pending_attack = nil
            end
            local recovery = data.pending_attack and data.pending_attack.recovery or 0.3
            if not data.pending_attack and data.attack_timer >= recovery then
                data.state = "idle"
                data.attack_timer = 0
                data.attack_kind = nil
            end
        elseif data.state == "blocking" and data.blocking then
            data.stamina = data.stamina - voxsoul.combat.constants.STAMINA_COST.block_per_sec * dt
            if data.stamina <= 0 then
                voxsoul.combat.state.force_state(data, "guardbreak")
                data.guardbreak_timer = 1.0
                data.blocking = false
            end
        elseif data.state == "hitstun" then
            data.hitstun_timer = (data.hitstun_timer or 0) - dt
            if data.hitstun_timer <= 0 then
                data.state = "idle"
            end
        elseif data.state == "guardbreak" then
            data.guardbreak_timer = (data.guardbreak_timer or 0) - dt
            if data.guardbreak_timer <= 0 then
                data.state = "idle"
            end
        end

        if data.state ~= "blocking" and data.state ~= "dodging" then
            data.dodge_chain = 0
        end

        if data.poise < data.max_poise and data.state ~= "hitstun" then
            data.poise = math.min(data.max_poise, data.poise + data.max_poise * voxsoul.combat.constants.POISE_RECOVER_RATE * dt)
        end

        local allow_regen = data.state ~= "blocking"
        data.stamina, data.regen_delay = voxsoul.combat.stamina.tick(
            data.stamina, data.max_stamina, dt, data.regen_delay or 0, allow_regen
        )

        local speed = 1.0
        local jump = 1.0
        if (data.hitstop_timer or 0) > 0 then
            speed = 0
            jump = 0
        elseif voxsoul.combat.stamina.is_exhausted(data.stamina, data.max_stamina) then
            speed = 0.7
        elseif data.blocking or data.state == "blocking" then
            speed = 0.5
        end
        if data.state == "dodging" then
            speed = 0.3
            jump = 0
        elseif data.state == "attacking" or data.state == "hitstun" or data.state == "guardbreak" then
            jump = 0
        end
        voxsoul.core.apply_physics(player, { speed = speed, jump = jump })
        voxsoul.combat.update_lockon_facing(player)
        if data.state ~= "dodging" and data.state ~= "hitstun" and data.state ~= "guardbreak"
            and (data.hitstop_timer or 0) <= 0 then
            voxsoul.combat.update_lockon_strafe(player, dt, speed)
        end

        if data.hp <= 0 and data.state ~= "dead" then
            data.state = "dead"
            if voxsoul.player then
                voxsoul.player.on_death(player)
            end
        elseif data.hp > 0 and data.state == "dead" then
            data.state = "idle"
        end
        voxsoul.combat.sync_engine_hp(player)
    end
end)

dofile(modpath .. "/tests.lua")
