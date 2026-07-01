voxsoul.ui = {}
dofile(minetest.get_modpath("voxsoul_ui") .. "/hud.lua")
dofile(minetest.get_modpath("voxsoul_ui") .. "/boss_hud.lua")
dofile(minetest.get_modpath("voxsoul_ui") .. "/lockon_marker.lua")

minetest.register_globalstep(function()
    for _, player in ipairs(minetest.get_connected_players()) do
        voxsoul.ui.update_player_hud(player)
        voxsoul.ui.update_lockon_marker(player)
    end
end)

minetest.register_on_leaveplayer(function(player)
    voxsoul.ui.clear_player_hud(player)
end)
