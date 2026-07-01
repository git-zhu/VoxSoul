voxsoul = rawget(_G, "voxsoul") or {}
voxsoul.VERSION = "0.1.0-dev"

dofile(minetest.get_modpath("voxsoul_core") .. "/storage.lua")
dofile(minetest.get_modpath("voxsoul_core") .. "/physics.lua")

minetest.log("action", "[voxsoul_core] Loading VoxSoul " .. voxsoul.VERSION)

minetest.register_on_joinplayer(function(player)
    voxsoul.core.apply_physics(player)
end)

dofile(minetest.get_modpath("voxsoul_core") .. "/disable_defaults.lua")
