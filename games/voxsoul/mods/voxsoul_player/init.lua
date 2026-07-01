voxsoul.player = {}
voxsoul.player.data = {}
voxsoul.player.stats = dofile(minetest.get_modpath("voxsoul_player") .. "/stats.lua")

local BASE_HP = 400
local BASE_STAMINA = 100
local MAX_RUNES = 999999

local function default_data()
    return {
        runes = 0,
        stats = { vigor = 0, endurance = 0, strength = 0, dexterity = 0 },
        graces = { gatefront = true },
        last_grace = "gatefront",
        weapon = "straight_sword",
        talisman = "",
    }
end

function voxsoul.player.load(player)
    local meta = player:get_meta()
    voxsoul.player.data[player:get_player_name()] = {
        runes = meta:get_int("voxsoul:runes"),
        stats = minetest.deserialize(meta:get_string("voxsoul:stats")) or default_data().stats,
        graces = minetest.deserialize(meta:get_string("voxsoul:graces")) or { gatefront = true },
        last_grace = meta:get_string("voxsoul:last_grace") or "gatefront",
        weapon = meta:get_string("voxsoul:weapon") or "straight_sword",
        talisman = meta:get_string("voxsoul:talisman") or "",
    }
end

function voxsoul.player.save(player)
    local name = player:get_player_name()
    local d = voxsoul.player.data[name]
    if not d then return end
    local meta = player:get_meta()
    meta:set_int("voxsoul:runes", d.runes)
    meta:set_string("voxsoul:stats", minetest.serialize(d.stats))
    meta:set_string("voxsoul:graces", minetest.serialize(d.graces))
    meta:set_string("voxsoul:last_grace", d.last_grace)
    meta:set_string("voxsoul:weapon", d.weapon)
    meta:set_string("voxsoul:talisman", d.talisman)
end

function voxsoul.player.get_runes(player)
    local d = voxsoul.player.data[player:get_player_name()]
    return d and d.runes or 0
end

function voxsoul.player.add_runes(player, amount)
    local d = voxsoul.player.data[player:get_player_name()]
    if not d then return end
    d.runes = math.min(MAX_RUNES, d.runes + amount)
end

function voxsoul.player.get_max_hp(player)
    local d = voxsoul.player.data[player:get_player_name()]
    local bonus = 0
    if d and d.talisman == "golden_blessing" then bonus = 5 end
    return voxsoul.player.stats.apply_vigor(BASE_HP + bonus, d and d.stats.vigor or 0)
end

function voxsoul.player.get_max_stamina(player)
    local d = voxsoul.player.data[player:get_player_name()]
    return voxsoul.player.stats.apply_endurance(BASE_STAMINA, d and d.stats.endurance or 0)
end

function voxsoul.player.get_dodge_cost(player, base_cost)
    local d = voxsoul.player.data[player:get_player_name()]
    return voxsoul.player.stats.apply_dexterity_dodge_cost(base_cost, d and d.stats.dexterity or 0)
end

function voxsoul.player.upgrade_stat(player, stat_name)
    local d = voxsoul.player.data[player:get_player_name()]
    if not d or not d.stats[stat_name] then return false end
    if d.stats[stat_name] >= 20 then return false end
    local cost = voxsoul.player.stats.upgrade_cost(d.stats[stat_name] + 1)
    if d.runes < cost then return false end
    d.runes = d.runes - cost
    d.stats[stat_name] = d.stats[stat_name] + 1
    voxsoul.combat.refresh_stats(player)
    local cd = voxsoul.combat.ensure_data(player)
    cd.max_hp = voxsoul.player.get_max_hp(player)
    cd.max_stamina = voxsoul.player.get_max_stamina(player)
    return true
end

function voxsoul.player.spawn_rune_pile(pos, amount)
    if amount <= 0 then return end
    minetest.add_entity(pos, "voxsoul_world:rune_pile", tostring(amount))
end

function voxsoul.player.on_death(player)
    local d = voxsoul.player.data[player:get_player_name()]
    local lost = voxsoul.player.stats.death_rune_loss(d.runes)
    d.runes = d.runes - lost
    voxsoul.player.spawn_rune_pile(player:get_pos(), lost)
    local grace_name = d.last_grace
    if voxsoul.ui then
        voxsoul.ui.show_death(player, lost, grace_name)
    end
    minetest.after(2, function()
        if not player:is_player() then return end
        if voxsoul.grace then voxsoul.grace.teleport_to_last_grace(player) end
        local cd = voxsoul.combat.ensure_data(player)
        cd.hp = cd.max_hp
        cd.stamina = cd.max_stamina
        cd.state = "idle"
    end)
end

function voxsoul.player.open_upgrade_menu(player)
    local d = voxsoul.player.data[player:get_player_name()]
    local form = "size[6,7]label[0,0;Upgrade - Runes: " .. d.runes .. "]"
    local y = 1
    for _, stat in ipairs({ "vigor", "endurance", "strength", "dexterity" }) do
        local lv = d.stats[stat]
        local cost = voxsoul.player.stats.upgrade_cost(lv + 1)
        form = form .. string.format("label[0,%f;%s Lv.%d next:%d]", y, stat, lv, cost)
        form = form .. string.format("button[4,%f;2,0.8;up_%s;+]", y, stat)
        y = y + 1
    end
    form = form .. "button[0,6;6,1;close;Close]"
    minetest.show_formspec(player:get_player_name(), "voxsoul:upgrade", form)
end

minetest.register_on_joinplayer(function(player)
    voxsoul.player.load(player)
    voxsoul.combat.refresh_stats(player)
end)

minetest.register_on_leaveplayer(function(player)
    voxsoul.player.save(player)
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "voxsoul:upgrade" then return end
    if fields.close then return end
    for key in pairs(fields) do
        if key:sub(1, 3) == "up_" then
            voxsoul.player.upgrade_stat(player, key:sub(4))
            voxsoul.player.open_upgrade_menu(player)
        end
    end
end)

assert(voxsoul.player.stats.upgrade_cost(3) == 300)
assert(voxsoul.player.stats.death_rune_loss(1001) == 500)
minetest.log("action", "[voxsoul_player] stats tests passed")
