-- Building blocks for the demo map
local function solid(tiles, groups)
    return {
        description = "VoxSoul block",
        tiles = tiles,
        groups = groups or { cracky = 2, unbreakable = 1 },
        paramtype = "light",
        sunlight_propagates = true,
    }
end

minetest.register_node("voxsoul_world:stone", solid({ "voxsoul_stone.png" }, { cracky = 3, unbreakable = 1 }))
minetest.register_node("voxsoul_world:grass", solid({ "voxsoul_grass.png", "voxsoul_stone.png" }, { crumbly = 3, unbreakable = 1 }))
minetest.register_node("voxsoul_world:brick", solid({ "voxsoul_brick.png" }))
minetest.register_node("voxsoul_world:dark_brick", solid({ "voxsoul_dark.png" }))
minetest.register_node("voxsoul_world:gold_trim", solid({ "voxsoul_gold.png" }, { cracky = 1, unbreakable = 1 }))

minetest.register_node("voxsoul_world:water", {
    description = "Water",
    drawtype = "liquid",
    tiles = { "voxsoul_water.png" },
    paramtype = "light",
    walkable = false,
    groups = { water = 3, unbreakable = 1 },
})

minetest.register_alias("mapgen_stone", "voxsoul_world:stone")
minetest.register_alias("mapgen_water_source", "voxsoul_world:water")
minetest.register_alias("mapgen_river_water_source", "voxsoul_world:water")
