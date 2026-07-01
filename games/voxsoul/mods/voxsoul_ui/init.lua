voxsoul.ui = {}
dofile(minetest.get_modpath("voxsoul_ui") .. "/hud.lua")

minetest.register_globalstep(function()
    for _, player in ipairs(minetest.get_connected_players()) do
        voxsoul.ui.update_player_hud(player)
    end
end)
