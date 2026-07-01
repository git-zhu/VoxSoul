local STONE = "voxsoul_world:stone"
local GRASS = "voxsoul_world:grass"
local LIGHT = "voxsoul_world:spawn_light"

local function to_blockpos(pos)
    return {
        x = math.floor(pos.x / 16),
        y = math.floor(pos.y / 16),
        z = math.floor(pos.z / 16),
    }
end

function voxsoul.world.get_spawn_pos()
    return voxsoul.world.SPAWN
end

local function is_inside_solid(pos)
    local node = minetest.get_node({
        x = math.floor(pos.x + 0.5),
        y = math.floor(pos.y + 0.01),
        z = math.floor(pos.z + 0.5),
    })
    local def = minetest.registered_nodes[node.name]
    return def and def.walkable
end

function voxsoul.world.place_player_on_spawn(player)
    local pos = voxsoul.world.get_spawn_pos()
    player:set_pos(pos)
    if is_inside_solid(player:get_pos()) then
        player:set_pos(vector.new(pos.x, pos.y + 1, pos.z))
    end
end

function voxsoul.world.ensure_spawn_pad()
    local floor_y = voxsoul.world.FLOOR_Y
    local p1 = vector.new(-12, floor_y - 2, -12)
    local p2 = vector.new(12, floor_y + 10, 12)
    minetest.load_area(p1, p2)

    for x = -12, 12 do
        for z = -12, 12 do
            local grass = minetest.get_node(vector.new(x, floor_y, z))
            if grass.name == "air" or grass.name == "ignore" then
                minetest.set_node(vector.new(x, floor_y - 1, z), { name = STONE })
                minetest.set_node(vector.new(x, floor_y, z), { name = GRASS })
            end
            for y = floor_y + 1, floor_y + 6 do
                minetest.set_node(vector.new(x, y, z), { name = "air" })
            end
        end
    end

    minetest.set_node(vector.new(0, floor_y + 1, 3), { name = "voxsoul_world:tutorial_sign" })
    minetest.set_node(vector.new(0, floor_y, 8), { name = "voxsoul_grace:site" })

    for _, p in ipairs({
        vector.new(-10, floor_y + 1, -10),
        vector.new(10, floor_y + 1, -10),
        vector.new(-10, floor_y + 1, 10),
        vector.new(10, floor_y + 1, 10),
    }) do
        minetest.set_node(p, { name = LIGHT })
    end
end

function voxsoul.world.sync_spawn_to_client(player)
    if not player or not player.send_mapblock then
        return
    end
    local pos = voxsoul.world.get_spawn_pos()
    minetest.load_area(
        vector.new(pos.x - 48, pos.y - 16, pos.z - 48),
        vector.new(pos.x + 48, pos.y + 48, pos.z + 48)
    )
    local bp = to_blockpos(pos)
    for x = bp.x - 1, bp.x + 1 do
        for y = bp.y - 1, bp.y + 1 do
            for z = bp.z - 1, bp.z + 1 do
                local blockpos = { x = x, y = y, z = z }
                minetest.forceload_block(blockpos, true)
                player:send_mapblock(blockpos)
            end
        end
    end
end

function voxsoul.world.setup_player(player)
    if not player or not player:is_player() then
        return
    end
    voxsoul.world.ensure_map()
    voxsoul.world.ensure_spawn_pad()
    if minetest.set_timeofday then
        minetest.set_timeofday(0.5)
    end
    voxsoul.world.place_player_on_spawn(player)
    player:set_look_horizontal(0)
    player:set_look_vertical(-0.2)
    if player.set_lighting then
        player:set_lighting({
            exposure = {
                luminance_min = -20,
                luminance_max = 20,
                exposure_correction = 1.5,
            },
        })
    end
    voxsoul.world.sync_spawn_to_client(player)
    local node = minetest.get_node(vector.new(0, voxsoul.world.FLOOR_Y, 0))
    minetest.log("action", "[voxsoul_spawn] player at "
        .. minetest.pos_to_string(player:get_pos())
        .. " floor node=" .. node.name)
end

return {}
