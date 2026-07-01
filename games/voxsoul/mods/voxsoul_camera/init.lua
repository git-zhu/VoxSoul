voxsoul.camera = {}

local EYE_FIRST = vector.new(0, 0, 0)
local EYE_THIRD = vector.new(0, 2.5, -4.5)
local EYE_THIRD_FRONT = vector.new(0, 2.5, 4.5)

function voxsoul.camera.apply(player)
    player:set_camera({ mode = "third" })
    player:set_eye_offset(EYE_FIRST, EYE_THIRD, EYE_THIRD_FRONT)
    player:set_fov(75)
end

minetest.register_on_joinplayer(function(player)
    voxsoul.camera.apply(player)
end)

minetest.register_on_leaveplayer(function(player)
    player:set_camera({ mode = "any" })
end)

-- 每 0.5s 强制第三人称，防止玩家切换
minetest.register_globalstep(function(dtime)
    voxsoul.camera._accum = (voxsoul.camera._accum or 0) + dtime
    if voxsoul.camera._accum < 0.5 then return end
    voxsoul.camera._accum = 0
    for _, player in ipairs(minetest.get_connected_players()) do
        player:set_camera({ mode = "third" })
    end
end)
