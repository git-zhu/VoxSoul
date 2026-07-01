local hud_ids = {}

local function bar(width, pct)
    local filled = math.floor(width * math.max(0, math.min(1, pct)))
    return string.rep("#", filled) .. string.rep("-", width - filled)
end

function voxsoul.ui.update_player_hud(player)
    local name = player:get_player_name()
    local d = voxsoul.combat.ensure_data(player)
    hud_ids[name] = hud_ids[name] or {}
    local ids = hud_ids[name]
    local hp_pct = d.hp / d.max_hp
    local st_pct = d.stamina / d.max_stamina
    local runes = voxsoul.player and voxsoul.player.get_runes(player) or 0
    local text = string.format("HP %s\nST %s\nRunes: %d", bar(16, hp_pct), bar(16, st_pct), runes)
    if not ids.main then
        ids.main = player:hud_add({
            type = "text",
            position = { x = 0.02, y = 0.85 },
            offset = { x = 0, y = 0 },
            scale = { x = 100, y = 100 },
            text = text,
            number = 0xFFFFFF,
        })
    else
        player:hud_change(ids.main, "text", text)
    end
end

local boss_huds = {}

function voxsoul.ui.show_boss_bar(boss_id, boss_name, hp, max_hp)
    for _, player in ipairs(minetest.get_connected_players()) do
        local pname = player:get_player_name()
        boss_huds[pname] = boss_huds[pname] or {}
        if boss_huds[pname][boss_id] then
            player:hud_change(boss_huds[pname][boss_id], "text",
                boss_name .. "\n" .. bar(24, hp / max_hp))
        else
            boss_huds[pname][boss_id] = player:hud_add({
                type = "text",
                name = "voxsoul_boss_" .. boss_id,
                position = { x = 0.5, y = 0.05 },
                offset = { x = -100, y = 0 },
                alignment = { x = 0, y = 0 },
                scale = { x = 150, y = 150 },
                text = boss_name .. "\n" .. bar(24, hp / max_hp),
                number = 0xFF4444,
            })
        end
    end
end

function voxsoul.ui.hide_boss_bar(boss_id)
    for _, player in ipairs(minetest.get_connected_players()) do
        local pname = player:get_player_name()
        if boss_huds[pname] and boss_huds[pname][boss_id] then
            player:hud_remove(boss_huds[pname][boss_id])
            boss_huds[pname][boss_id] = nil
        end
    end
end

function voxsoul.ui.show_death(player, lost, grace_name)
    minetest.show_formspec(player:get_player_name(), "voxsoul:death",
        "size[8,4]label[0,0;YOU DIED]label[0,1;Lost runes: " .. lost .. "]label[0,2;Revive at: " .. grace_name .. "]")
end
