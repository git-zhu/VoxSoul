local FLOOR_Y = 10
local STONE = "voxsoul_world:stone"
local BRICK = "voxsoul_world:brick"
local SPAWN = vector.new(0, FLOOR_Y + 1.5, 0)

function voxsoul.world.get_spawn_pos()
    return SPAWN
end

-- Emergency spawn pad: always ensure solid ground under the player.
function voxsoul.world.ensure_spawn_pad()
    minetest.load_area(
        vector.new(-16, FLOOR_Y - 2, -16),
        vector.new(16, FLOOR_Y + 8, 16)
    )
    for x = -8, 8 do
        for z = -8, 8 do
            minetest.set_node(vector.new(x, FLOOR_Y - 1, z), { name = STONE })
            minetest.set_node(vector.new(x, FLOOR_Y, z), { name = BRICK })
        end
    end
    minetest.set_node(vector.new(0, FLOOR_Y + 1, 2), { name = "voxsoul_world:tutorial_sign" })
    minetest.set_node(vector.new(0, FLOOR_Y, 12), { name = "voxsoul_grace:site" })
end

function voxsoul.world.setup_player(player)
    voxsoul.world.ensure_map()
    voxsoul.world.ensure_spawn_pad()
    if minetest.set_timeofday then
        minetest.set_timeofday(0.5)
    end
    player:set_pos(voxsoul.world.get_spawn_pos())
    player:set_look_horizontal(0)
    player:set_look_vertical(0)
end

return {
    FLOOR_Y = FLOOR_Y,
    SPAWN = SPAWN,
}
