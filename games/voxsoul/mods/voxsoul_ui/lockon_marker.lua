local markers = {}

local function hide_marker(player, name)
    local ids = markers[name]
    if not ids then
        return
    end
    if ids.image then
        player:hud_remove(ids.image)
    end
    markers[name] = nil
end

function voxsoul.ui.update_lockon_marker(player)
    local name = player:get_player_name()
    local target = voxsoul.combat.get_lock_target(player)
    if not target or not target:get_pos() then
        hide_marker(player, name)
        return
    end

    local tpos = target:get_pos()
    local world_pos = { x = tpos.x, y = tpos.y + 0.05, z = tpos.z }
    local ids = markers[name]

    if not ids then
        local image_id = player:hud_add({
            type = "image_waypoint",
            name = "voxsoul_lockon",
            scale = { x = 1.5, y = 1.5 },
            text = "voxsoul_lockon.png",
            world_pos = world_pos,
            offset = { x = 0, y = -16 },
            alignment = { x = 0, y = 0 },
            z_index = 50,
        })
        markers[name] = { image = image_id }
    else
        player:hud_change(ids.image, "world_pos", world_pos)
    end
end

minetest.register_on_leaveplayer(function(player)
    hide_marker(player, player:get_player_name())
end)
