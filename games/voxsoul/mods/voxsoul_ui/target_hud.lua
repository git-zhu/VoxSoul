local target_huds = {}

local function hide_target_hud(player, name)
    local ids = target_huds[name]
    if not ids then
        return
    end
    for _, id in pairs(ids) do
        player:hud_remove(id)
    end
    target_huds[name] = nil
end

local function get_target_name(obj)
    local ent = obj:get_luaentity()
    if not ent then
        return "Enemy"
    end
    if ent.boss_id and voxsoul.boss and voxsoul.boss.registry[ent.boss_id] then
        return voxsoul.boss.registry[ent.boss_id].name
    end
    if ent.name then
        return ent.name
    end
    return "Enemy"
end

local function get_target_hp(obj)
    local ent = obj:get_luaentity()
    if not ent then
        return 0, 100
    end
    return ent.hp or 0, ent.max_hp or ent.hp or 100
end

function voxsoul.ui.update_lock_target_hud(player)
    local name = player:get_player_name()
    local target = voxsoul.combat.get_lock_target(player)
    if not target or not target:get_luaentity() then
        hide_target_hud(player, name)
        return
    end

    local hp, max_hp = get_target_hp(target)
    local label = get_target_name(target)
    local bar_max = 24
    local filled = max_hp > 0 and math.floor(bar_max * hp / max_hp + 0.001) or 0
    filled = math.max(0, math.min(bar_max, filled))
    local text = string.format("%s  %d/%d", label, math.floor(hp), math.floor(max_hp))

    local ids = target_huds[name]
    if not ids then
        target_huds[name] = {
            name = player:hud_add({
                type = "text",
                position = { x = 0.5, y = 0.78 },
                offset = { x = 0, y = 0 },
                alignment = { x = 0, y = 0 },
                scale = { x = 130, y = 130 },
                text = text,
                number = 0xFFAA44,
                z_index = 150,
            }),
            bar = player:hud_add({
                type = "statbar",
                position = { x = 0.5, y = 0.82 },
                offset = { x = -192, y = 0 },
                size = { x = 16, y = 16 },
                text = "voxsoul_hp.png",
                text2 = "voxsoul_hp_bg.png",
                number = filled,
                item = bar_max,
                direction = 0,
                z_index = 150,
            }),
        }
    else
        player:hud_change(ids.name, "text", text)
        player:hud_change(ids.bar, "number", filled)
    end
end

minetest.register_on_leaveplayer(function(player)
    hide_target_hud(player, player:get_player_name())
end)
