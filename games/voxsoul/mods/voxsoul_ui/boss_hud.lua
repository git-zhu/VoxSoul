local boss_huds = {}
local BOSS_BAR_MAX = 20

local function bar_counts(hp, max_hp)
    if max_hp <= 0 then
        return 0, BOSS_BAR_MAX
    end
    return math.ceil(BOSS_BAR_MAX * hp / max_hp), BOSS_BAR_MAX
end

function voxsoul.ui.show_boss_bar(boss_id, boss_name, hp, max_hp)
    local num, bg = bar_counts(hp, max_hp)
    for _, player in ipairs(minetest.get_connected_players()) do
        local pname = player:get_player_name()
        boss_huds[pname] = boss_huds[pname] or {}
        local ids = boss_huds[pname][boss_id]
        if ids then
            player:hud_change(ids.name, "text", boss_name)
            player:hud_change(ids.bar, "number", num)
        else
            boss_huds[pname][boss_id] = {
                name = player:hud_add({
                    type = "text",
                    name = "voxsoul_boss_name_" .. boss_id,
                    position = { x = 0.5, y = 0.04 },
                    offset = { x = 0, y = 0 },
                    alignment = { x = 0, y = 0 },
                    scale = { x = 150, y = 150 },
                    text = boss_name,
                    number = 0xE8C878,
                    z_index = 200,
                }),
                bar = player:hud_add({
                    type = "statbar",
                    name = "voxsoul_boss_bar_" .. boss_id,
                    position = { x = 0.5, y = 0.08 },
                    offset = { x = -160, y = 0 },
                    size = { x = 16, y = 16 },
                    text = "voxsoul_boss_hp.png",
                    text2 = "voxsoul_boss_hp_bg.png",
                    number = num,
                    item = bg,
                    direction = 0,
                    z_index = 200,
                }),
            }
        end
    end
end

function voxsoul.ui.hide_boss_bar(boss_id)
    for _, player in ipairs(minetest.get_connected_players()) do
        local pname = player:get_player_name()
        local entry = boss_huds[pname] and boss_huds[pname][boss_id]
        if entry then
            player:hud_remove(entry.name)
            player:hud_remove(entry.bar)
            boss_huds[pname][boss_id] = nil
        end
    end
end

minetest.register_on_leaveplayer(function(player)
    boss_huds[player:get_player_name()] = nil
end)
