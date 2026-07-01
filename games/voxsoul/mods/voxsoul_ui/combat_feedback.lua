local flash_state = {}
local overlay_ids = {}

local MESSAGES = {
    hit = { text = "", color = 0xFF2222, overlay_tex = "voxsoul_flash_red.png", overlay = 0xFFFFFFFF },
    block = { text = "BLOCK", color = 0xC8D0E0, overlay_tex = "voxsoul_flash_gold.png", overlay = 0x88FFFFFF },
    parry = { text = "PARRY!", color = 0xFFD700, overlay_tex = "voxsoul_flash_gold.png", overlay = 0xCCFFFFFF },
    guardbreak = { text = "GUARD BROKEN", color = 0xFF8800, overlay_tex = "voxsoul_flash_red.png", overlay = 0xBBFFFFFF },
    boss_phase = { text = "", color = 0xFFD700, overlay_tex = "voxsoul_flash_gold.png", overlay = 0xAAFFFFFF },
}

function voxsoul.ui.combat_flash(player, kind, duration)
    local name = player:get_player_name()
    local cfg = MESSAGES[kind]
    if not cfg then
        return
    end
    flash_state[name] = {
        kind = kind,
        until_t = minetest.get_gametime() + (duration or 0.35),
    }
    if kind == "parry" then
        local pos = player:get_pos()
        minetest.add_particle({
            pos = { x = pos.x, y = pos.y + 1.2, z = pos.z },
            velocity = { x = 0, y = 1, z = 0 },
            acceleration = { x = 0, y = -2, z = 0 },
            expirationtime = 0.5,
            size = 2,
            texture = "voxsoul_gold.png",
            glow = 8,
        })
    end
end

function voxsoul.ui.update_combat_feedback(player)
    local name = player:get_player_name()
    local st = flash_state[name]
    local now = minetest.get_gametime()
    overlay_ids[name] = overlay_ids[name] or {}

    if not st or now > st.until_t then
        flash_state[name] = nil
        if overlay_ids[name].overlay then
            player:hud_remove(overlay_ids[name].overlay)
            overlay_ids[name].overlay = nil
        end
        if overlay_ids[name].text then
            player:hud_remove(overlay_ids[name].text)
            overlay_ids[name].text = nil
        end
        return
    end

    local cfg = MESSAGES[st.kind]
    if not overlay_ids[name].overlay then
        overlay_ids[name].overlay = player:hud_add({
            type = "image",
            position = { x = 0.5, y = 0.5 },
            offset = { x = 0, y = 0 },
            alignment = { x = 0, y = 0 },
            scale = { x = -200, y = -200 },
            text = cfg.overlay_tex or "voxsoul_flash_red.png",
            number = cfg.overlay,
            z_index = 500,
        })
    end
    if cfg.text ~= "" and not overlay_ids[name].text then
        overlay_ids[name].text = player:hud_add({
            type = "text",
            position = { x = 0.5, y = 0.45 },
            offset = { x = 0, y = 0 },
            alignment = { x = 0, y = 0 },
            scale = { x = 200, y = 200 },
            text = cfg.text,
            number = cfg.color,
            z_index = 501,
        })
    end
end

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    flash_state[name] = nil
    overlay_ids[name] = nil
end)
