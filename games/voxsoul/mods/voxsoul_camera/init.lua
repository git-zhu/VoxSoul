voxsoul.camera = {}

function voxsoul.camera.apply(player)
    if not player or not player:is_player() then
        return
    end
    -- Reset then apply (Luanti 5.16)
    if player.set_camera then
        player:set_camera(nil)
        player:set_camera({ mode = "third" })
    end
    -- Modest over-shoulder offset (within API clamp limits)
    if player.set_eye_offset then
        player:set_eye_offset(
            vector.new(0, 0, 0),
            vector.new(1.2, 2.0, -3.5),
            vector.new(0, 2.0, 3.5)
        )
    end
    if player.set_fov then
        player:set_fov(75)
    end
end

-- Teleport immediately so the client never renders a stale saved position.
minetest.register_on_joinplayer(function(player)
    if voxsoul.world and voxsoul.world.place_player_on_spawn then
        voxsoul.world.place_player_on_spawn(player)
    elseif voxsoul.world and voxsoul.world.get_spawn_pos then
        player:set_pos(voxsoul.world.get_spawn_pos())
    end
    -- First person until the spawn area is synced (avoids third-person void black screen)
    if player.set_camera then
        player:set_camera({ mode = "first" })
    end
end)

minetest.register_on_joinplayer(function(player)
    minetest.after(0.5, function()
        if not player:is_player() then return end
        if voxsoul.world then
            voxsoul.world.setup_player(player)
        end
        minetest.after(0.5, function()
            if player:is_player() then
                voxsoul.camera.apply(player)
            end
        end)
    end)
end)

minetest.register_on_leaveplayer(function(player)
    player:set_camera({ mode = "any" })
end)

minetest.register_globalstep(function(dtime)
    voxsoul.camera._accum = (voxsoul.camera._accum or 0) + dtime
    if voxsoul.camera._accum < 2.0 then
        return
    end
    voxsoul.camera._accum = 0
    for _, player in ipairs(minetest.get_connected_players()) do
        player:set_camera({ mode = "third" })
    end
end)
