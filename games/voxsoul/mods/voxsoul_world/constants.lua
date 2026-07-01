voxsoul.world = voxsoul.world or {}

voxsoul.world.MAP_VERSION = "3"
voxsoul.world.FLOOR_Y = 20
voxsoul.world.SPAWN = vector.new(0, voxsoul.world.FLOOR_Y + 1, 0)

function voxsoul.world.spawn_y()
    return voxsoul.world.FLOOR_Y + 1
end
