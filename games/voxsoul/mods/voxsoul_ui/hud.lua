local hud_ids = {}
local stamina_blink = {}
local STAMINA_BAR_MAX = 40
local HP_BAR_MAX = 40

local function statbar_count(current, maximum, bar_max)
    if maximum <= 0 then
        return 0, bar_max
    end
    local filled = math.floor(bar_max * current / maximum + 0.001)
    return math.max(0, math.min(bar_max, filled)), bar_max
end

local function stamina_display(name, d, st_num)
    if not voxsoul.combat.stamina.is_exhausted(d.stamina, d.max_stamina) then
        stamina_blink[name] = nil
        return st_num
    end
    local now = minetest.get_gametime()
    local blink = stamina_blink[name] or { last = now, visible = true }
    if now - blink.last >= 0.5 then
        blink.last = now
        blink.visible = not blink.visible
    end
    stamina_blink[name] = blink
    if blink.visible then
        return st_num
    end
    return 0
end

function voxsoul.ui.update_player_hud(player)
    local name = player:get_player_name()
    local d = voxsoul.combat.ensure_data(player)
    hud_ids[name] = hud_ids[name] or {}
    local ids = hud_ids[name]

    local hp_num, hp_bg = statbar_count(d.hp, d.max_hp, HP_BAR_MAX)
    local st_num, st_bg = statbar_count(d.stamina, d.max_stamina, STAMINA_BAR_MAX)
    st_num = stamina_display(name, d, st_num)

    local runes = voxsoul.player and voxsoul.player.get_runes(player) or 0
    local hp_text = string.format("HP %d/%d", math.floor(d.hp), math.floor(d.max_hp))
    local st_text = string.format("ST %d/%d", math.floor(d.stamina), math.floor(d.max_stamina))

    if not ids.hp then
        ids.hp = player:hud_add({
            type = "statbar",
            position = { x = 0.02, y = 0.90 },
            offset = { x = 4, y = 0 },
            size = { x = 16, y = 16 },
            text = "voxsoul_hp.png",
            text2 = "voxsoul_hp_bg.png",
            number = hp_num,
            item = hp_bg,
            direction = 0,
            z_index = 100,
        })
        ids.stamina = player:hud_add({
            type = "statbar",
            position = { x = 0.02, y = 0.94 },
            offset = { x = 4, y = 0 },
            size = { x = 16, y = 16 },
            text = "voxsoul_stamina.png",
            text2 = "voxsoul_stamina_bg.png",
            number = st_num,
            item = st_bg,
            direction = 0,
            z_index = 100,
        })
        ids.runes = player:hud_add({
            type = "text",
            position = { x = 0.75, y = 0.90 },
            offset = { x = 0, y = 0 },
            scale = { x = 120, y = 120 },
            text = "Runes: " .. runes,
            number = 0xFFD700,
            z_index = 100,
        })
        ids.hp_text = player:hud_add({
            type = "text",
            position = { x = 0.02, y = 0.86 },
            offset = { x = 4, y = 0 },
            scale = { x = 110, y = 110 },
            text = hp_text,
            number = 0xFF6666,
            z_index = 100,
        })
        ids.st_text = player:hud_add({
            type = "text",
            position = { x = 0.02, y = 0.98 },
            offset = { x = 4, y = 0 },
            scale = { x = 110, y = 110 },
            text = st_text,
            number = 0x66FF66,
            z_index = 100,
        })
    else
        player:hud_change(ids.hp, "number", hp_num)
        player:hud_change(ids.stamina, "number", st_num)
        player:hud_change(ids.runes, "text", "Runes: " .. runes)
        player:hud_change(ids.hp_text, "text", hp_text)
        player:hud_change(ids.st_text, "text", st_text)
    end
end

function voxsoul.ui.clear_player_hud(player)
    local name = player:get_player_name()
    local ids = hud_ids[name]
    if not ids then
        return
    end
    for _, id in pairs(ids) do
        player:hud_remove(id)
    end
    hud_ids[name] = nil
    stamina_blink[name] = nil
end

function voxsoul.ui.show_death(player, lost, grace_name)
    minetest.show_formspec(player:get_player_name(), "voxsoul:death",
        "size[8,4]label[0,0;YOU DIED]label[0,1;Lost runes: " .. lost .. "]label[0,2;Revive at: " .. grace_name .. "]")
end
