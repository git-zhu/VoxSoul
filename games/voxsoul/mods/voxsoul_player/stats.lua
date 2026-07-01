local MAX_LEVEL = 20
local M = {}

function M.upgrade_cost(current_level)
    return current_level * 100
end

function M.death_rune_loss(runes)
    return math.floor(runes * 0.5)
end

function M.apply_vigor(base_hp, level)
    return base_hp + level * 20
end

function M.apply_endurance(base_stamina, level)
    return base_stamina + level * 5
end

function M.apply_strength(mult, level)
    return mult * (1 + level * 0.03)
end

function M.apply_dexterity_damage(mult, level)
    return mult * (1 + level * 0.01)
end

function M.apply_dexterity_dodge_cost(base_cost, level)
    return math.floor(base_cost * (1 - level * 0.02))
end

return M
