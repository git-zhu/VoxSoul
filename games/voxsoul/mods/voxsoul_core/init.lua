voxsoul = rawget(_G, "voxsoul") or {}
voxsoul.VERSION = "0.1.0-dev"

minetest.log("action", "[voxsoul_core] Loading VoxSoul " .. voxsoul.VERSION)

minetest.register_on_joinplayer(function(player)
    player:set_physics_override({
        speed = 1.0,
        jump = 0,
        gravity = 1.0,
    })
end)
