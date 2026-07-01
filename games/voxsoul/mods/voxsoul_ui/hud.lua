local hud_ids = {}
local stamina_blink = {}
local STAMINA_BAR_MAX = 20
local HP_BAR_MAX = 20

local COL_HP = 0xE8D4C0
local COL_ST = 0xB8C878
local COL_RUNE = 0xD4B050
local COL_DIM = 0x908878

local function statbar_count(current, maximum, bar_max)
    if maximum <= 0 then
        return 0, bar_max
    end
    local filled = math.ceil(bar_max * current / maximum - 0.001)
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
    local loadout = voxsoul.items and voxsoul.items.get_loadout_text(player) or ""
    local hp_text = string.format("%d / %d", math.floor(d.hp), math.floor(d.max_hp))
    local st_text = string.format("%d / %d", math.floor(d.stamina), math.floor(d.max_stamina))
    local rune_text = string.format("卢恩  %d", runes)

    if not ids.hp then
        ids.hp = player:hud_add({
            type = "statbar",
            position = { x = 0.02, y = 0.92 },
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
            position = { x = 0.02, y = 0.96 },
            offset = { x = 4, y = 0 },
            size = { x = 16, y = 16 },
            text = "voxsoul_stamina.png",
            text2 = "voxsoul_stamina_bg.png",
            number = st_num,
            item = st_bg,
            direction = 0,
            z_index = 100,
        })
        ids.hp_text = player:hud_add({
            type = "text",
            position = { x = 0.28, y = 0.915 },
            offset = { x = 0, y = 0 },
            scale = { x = 95, y = 95 },
            text = hp_text,
            number = COL_HP,
            z_index = 100,
        })
        ids.st_text = player:hud_add({
            type = "text",
            position = { x = 0.28, y = 0.955 },
            offset = { x = 0, y = 0 },
            scale = { x = 95, y = 95 },
            text = st_text,
            number = COL_ST,
            z_index = 100,
        })
        ids.runes = player:hud_add({
            type = "text",
            position = { x = 0.75, y = 0.92 },
            offset = { x = 0, y = 0 },
            scale = { x = 115, y = 115 },
            text = rune_text,
            number = COL_RUNE,
            z_index = 100,
        })
        ids.loadout = player:hud_add({
            type = "text",
            position = { x = 0.75, y = 0.96 },
            offset = { x = 0, y = 0 },
            scale = { x = 90, y = 90 },
            text = loadout,
            number = COL_DIM,
            z_index = 100,
        })
    else
        player:hud_change(ids.hp, "number", hp_num)
        player:hud_change(ids.stamina, "number", st_num)
        player:hud_change(ids.hp_text, "text", hp_text)
        player:hud_change(ids.st_text, "text", st_text)
        player:hud_change(ids.runes, "text", rune_text)
        if ids.loadout then
            player:hud_change(ids.loadout, "text", loadout)
        end
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
        "size[10,5;true]" ..
        "bgcolor[#120e0c;true]" ..
        "label[0,0.5;YOU DIED]" ..
        "label[0,1.8;失去卢恩: " .. lost .. "]" ..
        "label[0,2.8;复活于: " .. grace_name .. "]")
end

function voxsoul.ui.show_demo_clear(player)
    local d = voxsoul.player and voxsoul.player.data[player:get_player_name()]
    local runes = d and d.runes or 0
    minetest.show_formspec(player:get_player_name(), "voxsoul:demo_clear",
        "size[10,5;true]" ..
        "bgcolor[#120e0c;true]" ..
        "label[0,0.5;DEMO COMPLETE]" ..
        "label[0,1.5;接肢葛瑞克已倒下。葛瑞克的大卢恩已入手。]" ..
        "label[0,2.5;持有卢恩: " .. runes .. "]" ..
        "button[3,3.5;4,1;ok;Continue]")
end
