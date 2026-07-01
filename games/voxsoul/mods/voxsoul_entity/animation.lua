function voxsoul.entity.play_anim(obj, range, speed, loop)
    if not obj or not obj.set_animation then
        return
    end
    obj:set_animation({ x = range[1], y = range[2] }, speed or 30, 0, loop ~= false)
end

function voxsoul.entity.register_mesh_entity(name, def)
    def.visual = "mesh"
    def.mesh = def.mesh or "voxsoul_entity_placeholder.b3d"
    def.textures = def.textures or { "voxsoul_placeholder.png" }
    def.static_save = def.static_save ~= false
    minetest.register_entity(name, def)
end
