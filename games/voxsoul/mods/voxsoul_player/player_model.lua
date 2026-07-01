voxsoul.player_model = {
    registered_models = {},
    player_attached = {},
}

local M = voxsoul.player_model
local models = M.registered_models
local players = {}
local animation_blend = 0

local function collisionbox_equals(a, b)
    if a == b then
        return true
    end
    for index = 1, 6 do
        if a[index] ~= b[index] then
            return false
        end
    end
    return true
end

function M.register_model(name, def)
    models[name] = def
    def.visual_size = def.visual_size or { x = 1, y = 1 }
    def.collisionbox = def.collisionbox or { -0.3, 0.0, -0.3, 0.3, 1.7, 0.3 }
    def.stepheight = def.stepheight or 0.6
    def.eye_height = def.eye_height or 1.47

    for animation_name, animation in pairs(def.animations) do
        animation.eye_height = animation.eye_height or def.eye_height
        animation.collisionbox = animation.collisionbox or def.collisionbox
        animation.override_local = animation.override_local or false

        for _, other_animation in pairs(def.animations) do
            if other_animation._equals then
                if collisionbox_equals(animation.collisionbox, other_animation.collisionbox)
                    and animation.eye_height == other_animation.eye_height
                then
                    animation._equals = other_animation._equals
                    break
                end
            end
        end
        animation._equals = animation._equals or animation_name
    end
end

local function get_player_data(player)
    return assert(players[player:get_player_name()])
end

function M.set_model(player, model_name)
    local player_data = get_player_data(player)
    if player_data.model == model_name then
        return
    end
    player_data.model = model_name
    player_data.animation, player_data.animation_speed, player_data.animation_loop = nil, nil, nil

    local model = models[model_name]
    if model then
        player:set_properties({
            mesh = model_name,
            textures = player_data.textures or model.textures,
            visual = "mesh",
            visual_size = model.visual_size,
            stepheight = model.stepheight,
        })
        M.set_animation(player, "stand")
    end
end

function M.set_animation(player, anim_name, speed, loop)
    local player_data = get_player_data(player)
    local model = models[player_data.model]
    if not (model and model.animations[anim_name]) then
        return
    end
    speed = speed or model.animation_speed
    if loop == nil then
        loop = true
    end
    if player_data.animation == anim_name
        and player_data.animation_speed == speed
        and player_data.animation_loop == loop
    then
        return
    end

    local previous_anim = model.animations[player_data.animation] or {}
    local anim = model.animations[anim_name]
    player_data.animation = anim_name
    player_data.animation_speed = speed
    player_data.animation_loop = loop

    if anim.override_local ~= previous_anim.override_local then
        if anim.override_local then
            player:set_local_animation({ x = 0, y = 0 }, { x = 0, y = 0 }, { x = 0, y = 0 }, { x = 0, y = 0 }, 1)
        else
            local a = model.animations
            player:set_local_animation(a.stand, a.walk, a.mine, a.walk_mine, model.animation_speed or 30)
        end
    end

    player:set_animation(anim, speed, animation_blend, loop)
    if anim._equals ~= previous_anim._equals then
        player:set_properties({
            collisionbox = anim.collisionbox,
            eye_height = anim.eye_height,
        })
    end
end

local function combat_animation(player)
    if not voxsoul.combat then
        return nil
    end
    local data = voxsoul.combat.ensure_data(player)
    if data.state == "dodging" then
        return "walk", 45
    end
    if data.state == "attacking" then
        return "mine", 35
    end
    if data.blocking or data.state == "blocking" then
        return "stand", 20
    end
    if data.state == "hitstun" or data.state == "guardbreak" then
        return "stand", 15
    end
    return nil
end

function M.globalstep()
    for _, player in ipairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        local player_data = players[name]
        local model = player_data and models[player_data.model]
        if model and not M.player_attached[name] then
            local forced_name, forced_speed = combat_animation(player)
            if forced_name then
                M.set_animation(player, forced_name, forced_speed)
            else
                local controls = player:get_player_control()
                local animation_speed_mod = model.animation_speed or 30
                if controls.sneak then
                    animation_speed_mod = animation_speed_mod / 2
                end

                if player:get_hp() == 0 then
                    M.set_animation(player, "lay")
                elseif controls.up or controls.down or controls.left or controls.right then
                    if controls.dig or controls.place then
                        M.set_animation(player, "walk_mine", animation_speed_mod)
                    else
                        M.set_animation(player, "walk", animation_speed_mod)
                    end
                elseif controls.dig or controls.place then
                    M.set_animation(player, "mine", animation_speed_mod)
                else
                    M.set_animation(player, "stand", animation_speed_mod)
                end
            end
        end
    end
end

M.register_model("voxsoul_tarnished.b3d", {
    animation_speed = 30,
    textures = { "voxsoul_tarnished.png" },
    animations = {
        stand = { x = 0, y = 79 },
        lay = {
            x = 162,
            y = 166,
            eye_height = 0.3,
            override_local = true,
            collisionbox = { -0.6, 0.0, -0.6, 0.6, 0.3, 0.6 },
        },
        walk = { x = 168, y = 187 },
        mine = { x = 189, y = 198 },
        walk_mine = { x = 200, y = 219 },
        sit = {
            x = 81,
            y = 160,
            eye_height = 0.8,
            override_local = true,
            collisionbox = { -0.3, 0.0, -0.3, 0.3, 1.0, 0.3 },
        },
    },
    collisionbox = { -0.3, 0.0, -0.3, 0.3, 1.7, 0.3 },
    stepheight = 0.6,
    eye_height = 1.47,
})

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    players[name] = {}
    M.player_attached[name] = false
    M.set_model(player, "voxsoul_tarnished.b3d")
end)

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    players[name] = nil
    M.player_attached[name] = nil
end)

minetest.register_globalstep(function()
    M.globalstep()
end)

return M
