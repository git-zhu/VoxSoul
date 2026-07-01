local FLOOR_Y = 10
local STONE = "voxsoul_world:stone"
local GRASS = "voxsoul_world:grass"
local BRICK = "voxsoul_world:brick"
local DARK = "voxsoul_world:dark_brick"
local GOLD = "voxsoul_world:gold_trim"
local TUTORIAL = "voxsoul_world:tutorial_sign"
local GRACE = "voxsoul_grace:site"

local function set_box(p1, p2, node)
    for x = p1.x, p2.x do
        for y = p1.y, p2.y do
            for z = p1.z, p2.z do
                minetest.set_node(vector.new(x, y, z), { name = node })
            end
        end
    end
end

local function set_floor(x1, z1, x2, z2, top_node)
    set_box(
        vector.new(x1, FLOOR_Y - 1, z1),
        vector.new(x2, FLOOR_Y - 1, z2),
        STONE
    )
    set_box(
        vector.new(x1, FLOOR_Y, z1),
        vector.new(x2, FLOOR_Y, z2),
        top_node or GRASS
    )
end

local function build_ruins()
    set_floor(-15, -15, 15, 15, BRICK)
    set_box(vector.new(-3, FLOOR_Y + 1, -3), vector.new(3, FLOOR_Y + 4, 3), BRICK)
    set_box(vector.new(-2, FLOOR_Y + 1, -2), vector.new(2, FLOOR_Y + 3, 2), "air")
    minetest.set_node(vector.new(0, FLOOR_Y + 1, 2), { name = TUTORIAL })
    minetest.set_node(vector.new(0, FLOOR_Y, 12), { name = GRACE })
end

local function build_road(x1, z1, x2, z2)
    set_floor(x1, z1, x2, z2, GRASS)
    local mid_z = math.floor((z1 + z2) / 2)
    set_box(vector.new(x1, FLOOR_Y, mid_z - 2), vector.new(x2, FLOOR_Y, mid_z + 2), "voxsoul_world:gold_trim")
end

local function build_sentinel_arena()
    set_floor(60, -20, 100, 20, GRASS)
    set_box(vector.new(75, FLOOR_Y + 1, -8), vector.new(85, FLOOR_Y + 1, 8), GOLD)
    minetest.set_node(vector.new(80, FLOOR_Y, -12), { name = GRACE })
end

local function build_margit_arena()
    set_floor(140, -30, 180, 30, BRICK)
    set_box(vector.new(150, FLOOR_Y + 1, -20), vector.new(170, FLOOR_Y + 8, 20), BRICK)
    set_box(vector.new(155, FLOOR_Y + 1, -15), vector.new(165, FLOOR_Y + 6, 15), "air")
    minetest.set_node(vector.new(160, FLOOR_Y, -25), { name = GRACE })
end

local function build_catacombs()
    set_floor(190, 30, 240, 70, DARK)
    set_box(vector.new(195, FLOOR_Y - 3, 35), vector.new(235, FLOOR_Y + 4, 65), DARK)
    set_box(vector.new(200, FLOOR_Y - 2, 40), vector.new(230, FLOOR_Y + 3, 60), "air")
    set_box(vector.new(225, FLOOR_Y - 2, 45), vector.new(230, FLOOR_Y + 1, 55), DARK)
    minetest.set_node(vector.new(200, FLOOR_Y, 35), { name = GRACE })
end

function voxsoul.world.build_map()
    minetest.log("action", "[voxsoul_world] Building demo map...")
    local p1 = vector.new(-30, FLOOR_Y - 5, -30)
    local p2 = vector.new(260, FLOOR_Y + 20, 80)
    minetest.load_area(p1, p2)

    build_ruins()
    build_road(16, -5, 59, 5)
    build_sentinel_arena()
    build_road(101, -5, 139, 5)
    build_margit_arena()
    build_road(181, -5, 189, 45)
    build_catacombs()

    minetest.set_node(vector.new(170, FLOOR_Y, 5), { name = GRACE })
    voxsoul.set_string("voxsoul:map_built", "1")
    minetest.log("action", "[voxsoul_world] Demo map build complete")
end

function voxsoul.world.ensure_map()
    if voxsoul.get_string("voxsoul:map_built") == "1" then
        return
    end
    voxsoul.world.build_map()
end
