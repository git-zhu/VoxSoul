-- Building blocks for the demo map
minetest.register_node("voxsoul_world:stone", {
    description = "Limgrave Stone",
    tiles = { "voxsoul_stone.png" },
    groups = { cracky = 3, unbreakable = 1 },
})

minetest.register_node("voxsoul_world:grass", {
    description = "Limgrave Grass",
    tiles = { "voxsoul_grass.png", "voxsoul_stone.png" },
    groups = { crumbly = 3, unbreakable = 1 },
})

minetest.register_node("voxsoul_world:brick", {
    description = "Ruin Brick",
    tiles = { "voxsoul_brick.png" },
    groups = { cracky = 2, unbreakable = 1 },
})

minetest.register_node("voxsoul_world:dark_brick", {
    description = "Catacombs Brick",
    tiles = { "voxsoul_dark.png" },
    groups = { cracky = 2, unbreakable = 1 },
})

minetest.register_node("voxsoul_world:gold_trim", {
    description = "Golden Trim",
    tiles = { "voxsoul_gold.png" },
    groups = { cracky = 1, unbreakable = 1 },
})

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
