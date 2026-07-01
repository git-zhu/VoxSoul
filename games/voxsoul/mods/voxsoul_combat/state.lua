local PRIORITY = {
    idle = 1,
    blocking = 2,
    attacking = 3,
    dodging = 4,
    guardbreak = 5,
    hitstun = 6,
}

local TRANSITIONS = {
    idle = { attacking = true, blocking = true, dodging = true },
    attacking = { idle = true, hitstun = true },
    blocking = { idle = true, hitstun = true, guardbreak = true },
    dodging = { idle = true, hitstun = true },
    hitstun = { idle = true },
    guardbreak = { idle = true },
}

local M = {}

function M.priority(state)
    return PRIORITY[state] or 0
end

function M.can_transition(from, to)
    local row = TRANSITIONS[from]
    return row and row[to] == true
end

function M.force_state(data, new_state)
    if M.priority(new_state) >= M.priority(data.state) then
        data.state = new_state
    end
end

return M
