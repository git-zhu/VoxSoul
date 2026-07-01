voxsoul.boss = {}
voxsoul.boss.registry = {}
voxsoul.boss.ai = dofile(minetest.get_modpath("voxsoul_boss") .. "/ai.lua")

local modpath = minetest.get_modpath("voxsoul_boss")

function voxsoul.boss.register(def)
    voxsoul.boss.registry[def.id] = def
end

for _, name in ipairs({ "tree_sentinel", "margit", "grafted_hag" }) do
    voxsoul.boss.register(dofile(modpath .. "/bosses/" .. name .. ".lua"))
end

function voxsoul.boss.is_defeated(boss_id)
    return voxsoul.get_string("voxsoul:boss:" .. boss_id) == "1"
end

function voxsoul.boss.on_defeated(boss_id, player)
    local def = voxsoul.boss.registry[boss_id]
    if not def then return end
    voxsoul.set_string("voxsoul:boss:" .. boss_id, "1")
    voxsoul.player.add_runes(player, def.runes)
    if def.drop and def.drop.weapon then
        voxsoul.items.equip_weapon(player, def.drop.weapon)
    end
    if def.drop and def.drop.talisman then
        voxsoul.items.equip_talisman(player, def.drop.talisman)
    end
    if boss_id == "margit" then
        voxsoul.grace.unlock(player, "after_margit")
    end
    if boss_id == "grafted_hag" and voxsoul.ui and voxsoul.ui.show_demo_clear then
        voxsoul.ui.show_demo_clear(player)
    end
    voxsoul.ui.hide_boss_bar(boss_id)
end

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
    return best
end

function voxsoul.boss.spawn(boss_id, pos)
    if voxsoul.boss.is_defeated(boss_id) then
        return nil
    end
    return minetest.add_entity(pos, "voxsoul_boss:entity", boss_id)
end

minetest.register_entity("voxsoul_boss:entity", {
    initial_properties = {
        visual = "sprite",
        textures = { "voxsoul_boss.png" },
        physical = true,
        collide_with_objects = true,
        collisionbox = { -0.5, 0, -0.5, 0.5, 2, 0.5 },
    },
    voxsoul_combatant = true,
    boss_id = "",
    hp = 100,
    max_hp = 100,
    poise = 50,
    max_poise = 50,
    on_activate = function(self, staticdata)
        self.object:set_armor_groups({ immortal = 1 })
        if staticdata and staticdata ~= "" then
            self.boss_id = staticdata
        end
        local def = voxsoul.boss.registry[self.boss_id]
        if def then
            self.hp = def.max_hp
            self.max_hp = def.max_hp
            self.poise = def.max_poise
            self.max_poise = def.max_poise
            local tex = def.sprite or "voxsoul_boss.png"
            self.object:set_properties({
                textures = { tex },
                visual_size = def.visual_size or { x = 2, y = 3 },
            })
        end
        self.brain = { state = "idle", timer = 0, last_attack = nil, phase_idx = 1 }
    end,
    get_staticdata = function(self)
        return self.boss_id or ""
    end,
    on_step = function(self, dtime)
        local def = voxsoul.boss.registry[self.boss_id]
        if not def then return end
        if self.stagger_timer and self.stagger_timer > 0 then
            self.stagger_timer = self.stagger_timer - dtime
            return
        end
local DEAGGRO_RANGE = 28
local DEAGGRO_TIME = 5

        local pos = self.object:get_pos()
        local target = find_nearest_player(pos, 20)
        local dist = target and vector.distance(pos, target:get_pos()) or DEAGGRO_RANGE + 1

        if not target or dist > DEAGGRO_RANGE then
            self.deaggro_timer = (self.deaggro_timer or 0) + dtime
            self.object:set_velocity({ x = 0, y = 0, z = 0 })
            if self.deaggro_timer >= DEAGGRO_TIME then
                self.hp = self.max_hp
                self.poise = self.max_poise
                self.brain.state = "idle"
                self.brain.timer = 0
                self.deaggro_timer = 0
                voxsoul.ui.hide_boss_bar(self.boss_id)
            end
            return
        end
        self.deaggro_timer = 0

        self.brain.timer = self.brain.timer - dtime
        local hp_ratio = self.hp / self.max_hp
        local phase_idx, phase = voxsoul.boss.ai.get_phase_index(def, hp_ratio)
        local display_name = def.name .. (phase.name_suffix or "")
        if phase_idx ~= (self.brain.phase_idx or 1) then
            self.brain.phase_idx = phase_idx
            for _, pl in ipairs(minetest.get_connected_players()) do
                minetest.chat_send_player(pl:get_player_name(), display_name)
                if voxsoul.ui and voxsoul.ui.combat_flash then
                    voxsoul.ui.combat_flash(pl, "boss_phase", 0.8)
                end
            end
        end
        voxsoul.ui.show_boss_bar(self.boss_id, display_name, self.hp, self.max_hp)

        if self.brain.state == "attack" then
            self.brain.elapsed = (self.brain.elapsed or 0) + dtime
            local atk = self.brain.current_atk
            if not self.brain.hit_applied and atk and self.brain.elapsed >= atk.windup then
                local tpos = target:get_pos()
                local hit = false
                local hb = atk.hitbox or { type = "circle", radius = 3 }
                if hb.type == "arc" then
                    local yaw = minetest.dir_to_yaw(vector.direction(pos, tpos))
                    hit = voxsoul.entity.hitbox.in_arc(pos, yaw, tpos, hb.radius or 3, hb.angle or 90)
                else
                    hit = voxsoul.entity.hitbox.in_circle(pos, tpos, hb.radius or 3)
                end
                if hit then
                    voxsoul.combat.hit_entity_with_attack(self.object, atk, target)
                end
                self.brain.hit_applied = true
            end
            if atk and self.brain.elapsed >= atk.windup + 0.5 then
                self.brain.state = "recovery"
                self.brain.timer = 0.5
            end
            return
        end
        if self.brain.state == "recovery" then
            self.brain.timer = self.brain.timer - dtime
            if self.brain.timer <= 0 then
                self.brain.state = "chase"
                self.brain.timer = 0.8
            end
            return
        end
        if dist > 12 then
            local tp = target:get_pos()
            local dir = vector.direction(pos, tp)
            self.object:set_velocity({ x = dir.x * 3, y = 0, z = dir.z * 3 })
            self.brain.state = "chase"
            return
        end
        if self.brain.timer <= 0 then
            local atk_name = voxsoul.boss.ai.pick_attack(phase.attacks, self.brain.last_attack)
            local atk = def.attacks[atk_name]
            if atk then
                self.brain.state = "attack"
                self.brain.elapsed = 0
                self.brain.hit_applied = false
                self.brain.current_atk = atk
                self.brain.last_attack = atk_name
                self.object:set_velocity({ x = 0, y = 0, z = 0 })
                local p = self.object:get_pos()
                local tex = def.sprite or "voxsoul_boss.png"
                minetest.add_particle({
                    pos = { x = p.x, y = p.y + 1, z = p.z },
                    velocity = { x = 0, y = 0.5, z = 0 },
                    expirationtime = atk.windup or 1,
                    size = 3,
                    texture = tex,
                    glow = 4,
                })
            end
        end
    end,
    on_hit = function(self, attacker, damage)
        if self.hp <= 0 then
            if attacker and attacker:is_player() then
                voxsoul.boss.on_defeated(self.boss_id, attacker)
            end
            self.object:remove()
        end
    end,
})

assert(voxsoul.boss.ai.pick_attack({ a = 1, b = 1 }, nil) ~= nil)
local idx = voxsoul.boss.ai.get_phase_index({ phases = { { threshold = 1.0 }, { threshold = 0.5 } } }, 0.4)
assert(idx == 2, "phase 2 below 50% hp")
idx = voxsoul.boss.ai.get_phase_index({ phases = { { threshold = 1.0 }, { threshold = 0.5 } } }, 0.8)
assert(idx == 1, "phase 1 above 50% hp")
minetest.log("action", "[voxsoul_boss] ai tests passed")
