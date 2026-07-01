voxsoul.storage = minetest.get_mod_storage()

function voxsoul.get_string(key)
    return voxsoul.storage:get_string(key) or ""
end

function voxsoul.set_string(key, value)
    voxsoul.storage:set_string(key, value)
end
