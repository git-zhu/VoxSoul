local modpath = minetest.get_modpath("voxsoul_combat")
local C = dofile(modpath .. "/constants.lua")

local lock_targets = {}
local lock_orbit = {}

local WALK_BASE = 4.0

local function flat_horizontal(vec)
    return { x = vec.x, y = 0, z = vec.z }
end

local function normalize_horizontal(vec)
    local flat = flat_horizontal(vec)
    local len = vector.length(flat)
    if len < 0.01 then
        return nil
    end
    return vector.multiply(flat, 1 / len)
end

-- Target-relative WASD: forward = toward target, left/right = orbit strafe.
function voxsoul.combat.compute_strafe_move(to_target, ctrl)
    local forward = normalize_horizontal(to_target)
    if not forward then
        return nil
    end
    local strafe_left = { x = -forward.z, y = 0, z = forward.x }
    local move = { x = 0, y = 0, z = 0 }
    if ctrl.up then
        move = vector.add(move, forward)
    end
    if ctrl.down then
        move = vector.subtract(move, forward)
    end
    if ctrl.left then
        move = vector.add(move, strafe_left)
    end
    if ctrl.right then
        move = vector.subtract(move, strafe_left)
    end
    local len = vector.length(move)
    if len < 0.01 then
        return nil
    end
    return vector.multiply(move, 1 / len)
end

local function find_nearest_enemy(player)
    local pos = player:get_pos()
    local best
    local best_dist = C.LOCKON_RANGE
    for _, obj in ipairs(minetest.get_objects_inside_radius(pos, C.LOCKON_RANGE)) do
        if not obj:is_player() then
            local ent = obj:get_luaentity()
            if ent and ent.voxsoul_combatant then
                local dist = vector.distance(pos, obj:get_pos())
                if dist < best_dist then
                    best = obj
                    best_dist = dist
                end
            end
        end
    end
    return best
end

function voxsoul.combat.toggle_lockon(player)
    local name = player:get_player_name()
    local current = lock_targets[name]
    if current and current:get_luaentity() then
        voxsoul.combat.clear_lockon(player)
        return
    end
    lock_targets[name] = find_nearest_enemy(player)
    lock_orbit[name] = 0
end

function voxsoul.combat.get_lock_target(player)
    local name = player:get_player_name()
    local obj = lock_targets[name]
    if not obj or not obj:get_luaentity() then
        lock_targets[name] = nil
        return nil
    end
    if vector.distance(player:get_pos(), obj:get_pos()) > C.LOCKON_BREAK_RANGE then
        lock_targets[name] = nil
        return nil
    end
    return obj
end

function voxsoul.combat.update_lockon_facing(player)
    local target = voxsoul.combat.get_lock_target(player)
    if not target then
        return
    end
    local pos = player:get_pos()
    local tpos = target:get_pos()
    if not tpos then
        return
    end
    local dir = vector.direction(pos, tpos)
    local yaw = minetest.dir_to_yaw(dir)
    player:set_look_horizontal(yaw)
    local horiz = math.sqrt(dir.x * dir.x + dir.z * dir.z)
    if horiz > 0.01 then
        local pitch = -math.atan2(dir.y, horiz)
        pitch = math.max(-0.6, math.min(0.4, pitch))
        player:set_look_vertical(pitch)
    end
end

function voxsoul.combat.update_lockon_strafe(player, dt, speed_mult)
    local target = voxsoul.combat.get_lock_target(player)
    if not target then
        return
    end
    local ctrl = player:get_player_control()
    if not (ctrl.up or ctrl.down or ctrl.left or ctrl.right) then
        return
    end
    local ppos = player:get_pos()
    local tpos = target:get_pos()
    if not tpos then
        return
    end
    local move = voxsoul.combat.compute_strafe_move(vector.subtract(tpos, ppos), ctrl)
    if not move then
        return
    end
    local speed = WALK_BASE * (speed_mult or 1.0)
    local vel = player:get_velocity()
    player:set_velocity({ x = move.x * speed, y = vel.y, z = move.z * speed })

    local name = player:get_player_name()
    local orbit = lock_orbit[name] or 0
    if ctrl.left and not ctrl.right then
        orbit = orbit + dt * 2.2
    elseif ctrl.right and not ctrl.left then
        orbit = orbit - dt * 2.2
    else
        local decay = math.min(1, dt * 3.0)
        orbit = orbit * (1 - decay)
    end
    lock_orbit[name] = orbit
    if voxsoul.camera and voxsoul.camera.apply_lockon_orbit then
        voxsoul.camera.apply_lockon_orbit(player, orbit)
    end
end

function voxsoul.combat.clear_lockon(player)
    local name = player:get_player_name()
    lock_targets[name] = nil
    lock_orbit[name] = nil
    if voxsoul.camera and voxsoul.camera.clear_lockon_orbit then
        voxsoul.camera.clear_lockon_orbit(player)
    end
end
