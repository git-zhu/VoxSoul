local M = {}

function M.get_phase(def, hp_ratio)
    local phase = def.phases[1]
    for _, p in ipairs(def.phases) do
        if hp_ratio <= p.threshold then
            phase = p
        end
    end
    return phase
end

function M.pick_attack(weights, last_attack)
    local pool = {}
    for atk, w in pairs(weights) do
        if atk == last_attack then
            w = w * 0.3
        end
        table.insert(pool, { atk = atk, w = w })
    end
    local total = 0
    for _, e in ipairs(pool) do
        total = total + e.w
    end
    if total <= 0 then return nil end
    local r = math.random() * total
    for _, e in ipairs(pool) do
        r = r - e.w
        if r <= 0 then
            return e.atk
        end
    end
    return pool[1].atk
end

return M
