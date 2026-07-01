voxsoul.world.enemy_ai = {}

local function find_nearest_player(pos, range)
    local best
    local best_dist = range
    for _, player in ipairs(minetest.get_connected_players()) do
        local dist = vector.distance(pos, player:get_pos())
        if dist < best_dist then
            best = player
            best_dist = dist
        end
    end
    return best, best_dist
end

---@param self table entity luaentity
---@param dtime number
---@param cfg table { chase_range, attack_range, damage, poise, windup, recovery, speed }
function voxsoul.world.enemy_ai.step(self, dtime, cfg)
    if self.stagger_timer and self.stagger_timer > 0 then
        self.stagger_timer = self.stagger_timer - dtime
        self.object:set_velocity({ x = 0, y = 0, z = 0 })
        return
    end
    if (self.hp or 0) <= 0 then
        return
    end

    cfg = cfg or {}
    local chase_range = cfg.chase_range or 18
    local attack_range = cfg.attack_range or 2.8
    local speed = cfg.speed or 4

    self.brain = self.brain or { state = "idle", timer = 0, elapsed = 0, hit_applied = false }
    local pos = self.object:get_pos()
    local target, dist = find_nearest_player(pos, chase_range)
    if not target then
        self.brain.state = "idle"
        self.object:set_velocity({ x = 0, y = 0, z = 0 })
        return
    end

    if self.brain.state == "attack" then
        self.brain.elapsed = self.brain.elapsed + dtime
        if not self.brain.hit_applied and self.brain.elapsed >= (cfg.windup or 0.7) then
            local tpos = target:get_pos()
            if vector.distance(pos, tpos) <= attack_range + 0.5 then
                voxsoul.combat.hit_entity_with_attack(self.object, {
                    damage = cfg.damage or 18,
                    poise = cfg.poise or 12,
                }, target)
            end
            self.brain.hit_applied = true
        end
        if self.brain.elapsed >= (cfg.windup or 0.7) + (cfg.recovery or 0.6) then
            self.brain.state = "chase"
            self.brain.timer = 0.5
        end
        self.object:set_velocity({ x = 0, y = 0, z = 0 })
        return
    end

    if self.brain.state == "recovery" then
        self.brain.timer = self.brain.timer - dtime
        if self.brain.timer <= 0 then
            self.brain.state = "chase"
        end
        return
    end

    if dist > attack_range then
        local tp = target:get_pos()
        local dir = vector.direction(pos, tp)
        self.object:set_velocity({ x = dir.x * speed, y = 0, z = dir.z * speed })
        self.brain.state = "chase"
        return
    end

    self.brain.timer = (self.brain.timer or 0) - dtime
    if self.brain.timer <= 0 then
        self.brain.state = "attack"
        self.brain.elapsed = 0
        self.brain.hit_applied = false
        self.brain.timer = (cfg.windup or 0.7) + (cfg.recovery or 0.6)
        self.object:set_velocity({ x = 0, y = 0, z = 0 })
    end
end

return voxsoul.world.enemy_ai
