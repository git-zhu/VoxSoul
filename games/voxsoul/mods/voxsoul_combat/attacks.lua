local modpath = minetest.get_modpath("voxsoul_combat")
local C = dofile(modpath .. "/constants.lua")

function voxsoul.combat.perform_attack(player, kind)
    local data = voxsoul.combat.ensure_data(player)
    if data.state ~= "idle" and data.state ~= "blocking" then
        return
    end
    local atk = kind == "heavy" and C.ATTACK.heavy or C.ATTACK.light
    local cost = kind == "heavy" and C.STAMINA_COST.heavy_attack or C.STAMINA_COST.light_attack
    if voxsoul.combat.stamina.is_exhausted(data.stamina, data.max_stamina) then
        return
    end
    if not voxsoul.combat.stamina.can_spend(data.stamina, cost) then
        return
    end
    data.stamina = data.stamina - cost
    data.state = "attacking"
    data.attack_kind = kind == "heavy" and "heavy" or "light"
    data.attack_timer = 0
    data.pending_attack = atk
    data.regen_delay = C.STAMINA_REGEN_DELAY_ATTACK
    if data.blocking then
        data.blocking = false
    end
end

function voxsoul.combat.apply_damage_to_entity(obj, damage, poise_damage, attacker)
    local ent = obj:get_luaentity()
    if not ent then
        return
    end
    ent.hp = (ent.hp or 100) - damage
    ent.poise = (ent.poise or 50) - poise_damage
    if ent.poise <= 0 then
        ent.stagger_timer = 1.2
        ent.poise = ent.max_poise or 50
    end
    if ent.on_hit then
        ent.on_hit(ent, attacker, damage)
    end
    if ent.hp <= 0 and ent.on_death then
        ent.on_death(ent, attacker)
    end
end

function voxsoul.combat.apply_damage_to_player(player, damage, poise_damage, attacker)
    local data = voxsoul.combat.ensure_data(player)
    if voxsoul.combat.is_invincible(player) then
        return
    end
    if data.blocking then
        local hit_time = minetest.get_gametime()
        if voxsoul.combat.try_parry(player, hit_time) then
            if attacker and attacker:get_luaentity() then
                attacker:get_luaentity().stagger_timer = C.PARRY.stagger
            end
            return
        end
        damage = voxsoul.combat.apply_block_damage(player, damage)
    end
    data.hp = data.hp - damage
    data.poise = data.poise - poise_damage
    if data.poise <= 0 then
        voxsoul.combat.state.force_state(data, "hitstun")
        data.hitstun_timer = 1.2
        data.poise = data.max_poise
    else
        voxsoul.combat.state.force_state(data, "hitstun")
        data.hitstun_timer = damage >= 40 and 0.5 or 0.2
    end
    if data.hp <= 0 then
        data.state = "dead"
    end
    voxsoul.combat.sync_engine_hp(player)
end

function voxsoul.combat.resolve_attack_hit(player, atk)
    local pos = player:get_pos()
    local yaw = player:get_look_horizontal()
    local weapon_mult = 1.0
    if voxsoul.items then
        weapon_mult = voxsoul.items.get_damage_mult(player)
    end
    local damage = atk.base_damage * weapon_mult
    for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 3.0)) do
        if obj:is_player() then
            goto continue
        end
        local ent = obj:get_luaentity()
        if ent and ent.voxsoul_combatant then
            local tpos = obj:get_pos()
            if voxsoul.entity.hitbox.in_arc(pos, yaw, tpos, 2.5, 90) then
                local final = damage
                if ent.stagger_timer and ent.stagger_timer > 0 then
                    final = final * 1.5
                end
                voxsoul.combat.apply_damage_to_entity(obj, final, atk.poise, player)
            end
        end
        ::continue::
    end
end

function voxsoul.combat.hit_entity_with_attack(attacker_obj, atk_def, target)
    if not target or not target:get_pos() then
        return
    end
    if target:is_player() then
        voxsoul.combat.apply_damage_to_player(target, atk_def.damage, atk_def.poise or 20, attacker_obj)
        return
    end
    voxsoul.combat.apply_damage_to_entity(target, atk_def.damage, atk_def.poise or 20, attacker_obj)
end
