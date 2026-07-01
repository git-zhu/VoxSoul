voxsoul.camera = {}

local EYE_FIRST = vector.new(0, 0, 0)
-- Over-shoulder: slightly above and behind the player (Luanti third-person offset)
local EYE_THIRD = vector.new(0.8, 1.4, -3.2)
local EYE_THIRD_FRONT = vector.new(0, 1.4, 3.2)

function voxsoul.camera.apply(player)
    player:set_camera({ mode = "third" })
    player:set_eye_offset(EYE_FIRST, EYE_THIRD, EYE_THIRD_FRONT)
    player:set_fov(75)
end

minetest.register_on_joinplayer(function(player)
    minetest.after(0.5, function()
        if player:is_player() then
            voxsoul.camera.apply(player)
        end
    end)
end)

minetest.register_on_leaveplayer(function(player)
    player:set_camera({ mode = "any" })
end)

-- Re-apply third person periodically (disable first-person toggle)
minetest.register_globalstep(function(dtime)
    voxsoul.camera._accum = (voxsoul.camera._accum or 0) + dtime
    if voxsoul.camera._accum < 1.0 then
        return
    end
    voxsoul.camera._accum = 0
    for _, player in ipairs(minetest.get_connected_players()) do
        player:set_camera({ mode = "third" })
    end
end)
