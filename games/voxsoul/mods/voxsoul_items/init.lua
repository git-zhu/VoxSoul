voxsoul.items = {}

local WEAPONS = {
    straight_sword = { damage_mult = 1.0, speed_mult = 1.0 },
    curved_sword = { damage_mult = 0.85, speed_mult = 1.2 },
}

function voxsoul.items.get_damage_mult(player)
    local d = voxsoul.player.data[player:get_player_name()]
    local w = WEAPONS[d.weapon] or WEAPONS.straight_sword
    local mult = w.damage_mult
    mult = voxsoul.player.stats.apply_strength(mult, d.stats.strength)
    mult = voxsoul.player.stats.apply_dexterity_damage(mult, d.stats.dexterity)
    return mult
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
