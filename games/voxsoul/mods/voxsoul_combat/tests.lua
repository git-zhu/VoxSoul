local modpath = minetest.get_modpath("voxsoul_combat")
local stamina = dofile(modpath .. "/stamina.lua")
local state = dofile(modpath .. "/state.lua")
local dodge = dofile(modpath .. "/dodge.lua")

assert(stamina.can_spend(22, 22) == true)
assert(stamina.can_spend(21, 22) == false)

local cur, delay = stamina.tick(0, 100, 0.1, 0, true)
assert(cur > 0)

assert(state.can_transition("idle", "attacking") == true)
assert(state.can_transition("hitstun", "attacking") == false)
assert(state.priority("hitstun") > state.priority("idle"))

assert(dodge.is_in_iframes(0.05, 0.6) == false)
assert(dodge.is_in_iframes(0.2, 0.6) == true)
assert(dodge.is_in_iframes(0.55, 0.6) == false)

minetest.log("action", "[voxsoul_combat] stamina/state tests passed")
