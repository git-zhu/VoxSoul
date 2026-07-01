voxsoul.core = voxsoul.core or {}
voxsoul.core.is_digging_disabled = true

local function disable_item_use(itemstack, player, pointed_thing)
    return itemstack
end

minetest.register_on_joinplayer(function(player, last_login)
    local name = player:get_player_name()
    local inv = player:get_inventory()
    inv:set_size("main", 8)
    inv:set_size("craft", 0)
    player:hud_set_flags({
        hotbar = false,
        healthbar = false,
        crosshair = true,
        wielditem = false,
    })
end)

minetest.register_on_dignode(function(pos, oldnode, digger)
    if digger and digger:is_player() then
        return true
    end
end)

minetest.register_on_placenode(function(itemstack, placer)
    if placer and placer:is_player() then
        return itemstack
    end
end)

minetest.register_on_punchplayer(function(player)
    return true
end)

minetest.register_chatcommand("voxsoul", {
    params = "unstuck",
    description = "VoxSoul debug commands",
    func = function(name, param)
        if param == "unstuck" then
            local player = minetest.get_player_by_name(name)
            if player and voxsoul.grace then
                voxsoul.grace.teleport_to_last_grace(player)
            end
            return true, "Teleported to last grace."
        end
        return false, "Usage: /voxsoul unstuck"
    end,
})
