local M = {}

local function flat_dir(from, to)
    local dx = to.x - from.x
    local dz = to.z - from.z
    local len = math.sqrt(dx * dx + dz * dz)
    if len < 0.001 then
        return 0, 0
    end
    return dx / len, dz / len
end

function M.in_circle(origin, target_pos, radius)
    local dx = target_pos.x - origin.x
    local dz = target_pos.z - origin.z
    return (dx * dx + dz * dz) <= radius * radius
end

function M.in_arc(origin, yaw, target_pos, radius, angle_deg)
    if not M.in_circle(origin, target_pos, radius) then
        return false
    end
    local tdx, tdz = flat_dir(origin, target_pos)
    local facing_x = -math.sin(yaw)
    local facing_z = math.cos(yaw)
    local dot = facing_x * tdx + facing_z * tdz
    local half_angle = math.rad(angle_deg / 2)
    return dot >= math.cos(half_angle)
end

return M
