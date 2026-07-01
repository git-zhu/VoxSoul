voxsoul.items = {}

local WEAPONS = {
    straight_sword = { name = "Straight Sword", damage_mult = 1.0, speed_mult = 1.0 },
    curved_sword = { name = "Curved Sword", damage_mult = 0.85, speed_mult = 1.2 },
}

local TALISMANS = {
    golden_blessing = { name = "Golden Blessing" },
}

function voxsoul.items.get_damage_mult(player)
    local d = voxsoul.player.data[player:get_player_name()]
    local w = WEAPONS[d.weapon] or WEAPONS.straight_sword
    local mult = w.damage_mult
    mult = voxsoul.player.stats.apply_strength(mult, d.stats.strength)
    mult = voxsoul.player.stats.apply_dexterity_damage(mult, d.stats.dexterity)
    return mult
end

function voxsoul.items.get_weapon_name(player)
    local d = voxsoul.player.data[player:get_player_name()]
    local w = WEAPONS[d and d.weapon or "straight_sword"] or WEAPONS.straight_sword
    return w.name
end

function voxsoul.items.get_talisman_name(talisman_id)
    local t = TALISMANS[talisman_id]
    return t and t.name or ""
end

function voxsoul.items.get_loadout_text(player)
    local weapon = voxsoul.items.get_weapon_name(player)
    local d = voxsoul.player.data[player:get_player_name()]
    local talisman = d and voxsoul.items.get_talisman_name(d.talisman) or ""
    if talisman ~= "" then
        return weapon .. "  ·  " .. talisman
    end
    return weapon
end

function voxsoul.items.equip_weapon(player, weapon_id)
    local d = voxsoul.player.data[player:get_player_name()]
    if WEAPONS[weapon_id] then
        d.weapon = weapon_id
    end
end

function voxsoul.items.equip_talisman(player, talisman_id)
    local d = voxsoul.player.data[player:get_player_name()]
    d.talisman = talisman_id
    voxsoul.combat.refresh_stats(player)
    local cd = voxsoul.combat.ensure_data(player)
    cd.max_hp = voxsoul.player.get_max_hp(player)
end
