local hitbox = dofile(minetest.get_modpath("voxsoul_entity") .. "/hitbox.lua")

local origin = vector.new(0, 0, 0)
local yaw = 0

-- yaw=0 faces +Z in Luanti; 90 deg arc is +/- 45 from forward
assert(hitbox.in_arc(origin, yaw, vector.new(0, 0, 1), 2.5, 90) == true)
assert(hitbox.in_arc(origin, yaw, vector.new(0, 0, -1), 2.5, 90) == false)
assert(hitbox.in_circle(origin, vector.new(1, 0, 0), 2.0) == true)
assert(hitbox.in_circle(origin, vector.new(3, 0, 0), 2.0) == false)

minetest.log("action", "[voxsoul_entity] hitbox tests passed")
