local FLOOR_Y = voxsoul.world.FLOOR_Y
local STONE = "voxsoul_world:stone"
local GRASS = "voxsoul_world:grass"
local BRICK = "voxsoul_world:brick"
local DARK = "voxsoul_world:dark_brick"
local GOLD = "voxsoul_world:gold_trim"
local LIGHT = "voxsoul_world:spawn_light"
local TUTORIAL = "voxsoul_world:tutorial_sign"
local LORE = "voxsoul_world:lore_sign"
local GRACE = "voxsoul_grace:site"

local function set_lore_sign(pos, text)
    minetest.set_node(pos, { name = LORE })
    local meta = minetest.get_meta(pos)
    if meta then
        meta:set_string("text", text)
    end
end

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

local function build_tutorial_ruins()
    set_floor(-15, -15, 15, 15, GRASS)
    set_box(vector.new(-3, FLOOR_Y + 1, -3), vector.new(3, FLOOR_Y + 4, 3), BRICK)
    set_box(vector.new(-2, FLOOR_Y + 1, -2), vector.new(2, FLOOR_Y + 3, 2), "air")
    minetest.set_node(vector.new(0, FLOOR_Y + 1, 3), { name = TUTORIAL })
    minetest.set_node(vector.new(0, FLOOR_Y, 8), { name = GRACE })
    for _, p in ipairs({
        vector.new(-10, FLOOR_Y + 1, -10),
        vector.new(10, FLOOR_Y + 1, -10),
        vector.new(-10, FLOOR_Y + 1, 10),
        vector.new(10, FLOOR_Y + 1, 10),
    }) do
        minetest.set_node(p, { name = LIGHT })
    end
end

local function build_road(x1, z1, x2, z2)
    set_floor(x1, z1, x2, z2, GRASS)
    local mid_z = math.floor((z1 + z2) / 2)
    set_box(vector.new(x1, FLOOR_Y, mid_z - 2), vector.new(x2, FLOOR_Y, mid_z + 2), GOLD)
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

local function build_stormveil_gate()
    set_floor(180, -15, 200, 15, BRICK)
    set_box(vector.new(183, FLOOR_Y + 1, -6), vector.new(197, FLOOR_Y + 8, 6), BRICK)
    set_box(vector.new(186, FLOOR_Y + 1, -3), vector.new(194, FLOOR_Y + 6, 3), "air")
    minetest.set_node(vector.new(185, FLOOR_Y, 0), { name = GOLD })
    set_lore_sign(vector.new(190, FLOOR_Y + 1, 0), "史东薇尔城——恶兆妖鬼把守的雾墙之后，接肢的半王等待挑战者。")
end

local function build_stormveil_courtyard()
    set_floor(200, -20, 225, 20, BRICK)
    set_box(vector.new(202, FLOOR_Y + 1, -18), vector.new(222, FLOOR_Y + 5, 18), BRICK)
    set_box(vector.new(205, FLOOR_Y + 1, -15), vector.new(220, FLOOR_Y + 4, 15), "air")
    minetest.set_node(vector.new(205, FLOOR_Y, 0), { name = GOLD })
end

local function build_stormveil_side_path()
    set_floor(200, -38, 228, -12, DARK)
    set_box(vector.new(203, FLOOR_Y + 1, -36), vector.new(225, FLOOR_Y + 4, -14), DARK)
    set_box(vector.new(206, FLOOR_Y + 1, -33), vector.new(222, FLOOR_Y + 3, -17), "air")
    minetest.set_node(vector.new(210, FLOOR_Y, -25), { name = GRACE })
    set_lore_sign(vector.new(212, FLOOR_Y + 1, -20), "侧室赐福——许多褪色者在此稍作喘息，再向接肢大厅进发。")
end

local function build_stormveil_hall()
    set_floor(226, -5, 265, 35, DARK)
    set_box(vector.new(228, FLOOR_Y + 1, 0), vector.new(262, FLOOR_Y + 6, 30), DARK)
    set_box(vector.new(232, FLOOR_Y + 1, 4), vector.new(258, FLOOR_Y + 5, 26), "air")
    set_box(vector.new(250, FLOOR_Y + 1, 10), vector.new(255, FLOOR_Y + 4, 20), GOLD)
    minetest.set_node(vector.new(235, FLOOR_Y, 8), { name = GRACE })
    set_lore_sign(vector.new(255, FLOOR_Y + 1, 15), "接肢葛瑞克——宁姆格福的半王。击败他，取得大卢恩。")
end

local function build_road_to_stormveil()
    build_road(181, -5, 199, 5)
    build_road(201, -5, 225, 5)
    build_road(226, 5, 254, 15)
end

function voxsoul.world.build_map()
    minetest.log("action", "[voxsoul_world] Building demo map v" .. voxsoul.world.MAP_VERSION .. "...")
    local p1 = vector.new(-30, FLOOR_Y - 5, -45)
    local p2 = vector.new(270, FLOOR_Y + 25, 85)
    minetest.load_area(p1, p2)

    build_tutorial_ruins()
    build_road(16, -5, 59, 5)
    build_sentinel_arena()
    build_road(101, -5, 139, 5)
    build_margit_arena()
    build_road_to_stormveil()
    build_stormveil_gate()
    build_stormveil_courtyard()
    build_stormveil_side_path()
    build_stormveil_hall()

    minetest.set_node(vector.new(170, FLOOR_Y, 5), { name = GRACE })
    voxsoul.set_string("voxsoul:map_version", voxsoul.world.MAP_VERSION)
    minetest.log("action", "[voxsoul_world] Demo map v" .. voxsoul.world.MAP_VERSION .. " build complete")
end

function voxsoul.world.ensure_map()
    if voxsoul.get_string("voxsoul:map_version") == voxsoul.world.MAP_VERSION then
        return
    end
    voxsoul.world.build_map()
end
