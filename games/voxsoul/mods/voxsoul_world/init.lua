voxsoul.world = {}
voxsoul.world._edge = {}
voxsoul.world.enemy_spawns = {}

local modpath = minetest.get_modpath("voxsoul_world")
dofile(modpath .. "/constants.lua")
dofile(modpath .. "/nodes.lua")
dofile(modpath .. "/map_builder.lua")
dofile(modpath .. "/spawn.lua")
dofile(modpath .. "/enemy_ai.lua")

function voxsoul.world.respawn_enemies()
    for _, spawn in ipairs(voxsoul.world.enemy_spawns) do
        if spawn.entity and spawn.entity:get_luaentity() then
            spawn.entity:remove()
        end
        spawn.entity = minetest.add_entity(spawn.pos, spawn.name)
    end
end

minetest.register_entity("voxsoul_world:knight", {
    initial_properties = {
        visual = "sprite",
        textures = { "voxsoul_enemy_knight.png" },
        visual_size = { x = 1.2, y = 2.2 },
        physical = true,
        collisionbox = { -0.4, 0, -0.4, 0.4, 1.8, 0.4 },
    },
    voxsoul_combatant = true,
    hp = 150,
    max_hp = 150,
    max_poise = 40,
    poise = 40,
    runes = 100,
    name = "Banished Knight",
    on_activate = function(self)
        self.object:set_armor_groups({ immortal = 1 })
        self.max_hp = self.max_hp or 150
        self.hp = self.hp or self.max_hp
    end,
    on_step = function(self, dtime)
        voxsoul.world.enemy_ai.step(self, dtime, {
            chase_range = 20,
            attack_range = 2.8,
            damage = 22,
            poise = 12,
            windup = 0.75,
            recovery = 0.55,
            speed = 4.5,
        })
    end,
    on_hit = function(self, attacker, damage)
        if self.hp <= 0 then
            if attacker and attacker:is_player() then
                voxsoul.player.add_runes(attacker, self.runes)
            end
            self.object:remove()
        end
    end,
})

minetest.register_entity("voxsoul_world:omen_freak", {
    initial_properties = {
        visual = "sprite",
        textures = { "voxsoul_enemy_omen.png" },
        visual_size = { x = 1.0, y = 1.8 },
        physical = true,
        collisionbox = { -0.4, 0, -0.4, 0.4, 1.5, 0.4 },
    },
    voxsoul_combatant = true,
    hp = 80,
    max_hp = 80,
    max_poise = 20,
    poise = 20,
    runes = 50,
    name = "Omen Freak",
    on_activate = function(self)
        self.object:set_armor_groups({ immortal = 1 })
        self.max_hp = self.max_hp or 80
        self.hp = self.hp or self.max_hp
    end,
    on_step = function(self, dtime)
        voxsoul.world.enemy_ai.step(self, dtime, {
            chase_range = 16,
            attack_range = 2.5,
            damage = 16,
            poise = 8,
            windup = 0.55,
            recovery = 0.45,
            speed = 5,
        })
    end,
    on_hit = function(self, attacker, damage)
        if self.hp <= 0 then
            if attacker and attacker:is_player() then
                voxsoul.player.add_runes(attacker, self.runes)
            end
            self.object:remove()
        end
    end,
})

minetest.register_entity("voxsoul_world:rune_pile", {
    initial_properties = {
        visual = "sprite",
        textures = { "voxsoul_rune.png" },
        physical = false,
    },
    amount = 0,
    on_activate = function(self, staticdata)
        self.object:set_armor_groups({ immortal = 1 })
        if staticdata and staticdata ~= "" then
            self.amount = tonumber(staticdata) or 0
        end
        minetest.after(600, function()
            if self.object then self.object:remove() end
        end)
    end,
    on_punch = function(self, hitter)
        if hitter:is_player() and self.amount > 0 then
            voxsoul.player.add_runes(hitter, self.amount)
            self.object:remove()
        end
    end,
    get_staticdata = function(self)
        return tostring(self.amount or 0)
    end,
})

function voxsoul.world.try_pickup_runes(player)
    local pos = player:get_pos()
    for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 2.5)) do
        if not obj:is_player() then
            local ent = obj:get_luaentity()
            if ent and ent.amount and ent.amount > 0 then
                voxsoul.player.add_runes(player, ent.amount)
                obj:remove()
                return true
            end
        end
    end
    return false
end

local function register_spawn(pos, name)
    table.insert(voxsoul.world.enemy_spawns, { pos = pos, name = name, entity = nil })
end

minetest.register_on_mods_loaded(function()
    local sy = voxsoul.world.spawn_y()
    register_spawn(vector.new(50, sy, 5), "voxsoul_world:knight")
    register_spawn(vector.new(55, sy, -5), "voxsoul_world:knight")
    register_spawn(vector.new(205, sy, 3), "voxsoul_world:omen_freak")
    register_spawn(vector.new(208, sy, -3), "voxsoul_world:omen_freak")
    register_spawn(vector.new(215, sy, -22), "voxsoul_world:knight")
    register_spawn(vector.new(245, sy, 12), "voxsoul_world:omen_freak")
    register_spawn(vector.new(248, sy, 18), "voxsoul_world:omen_freak")
end)

minetest.register_on_mods_loaded(function()
    voxsoul.world.ensure_map()
end)

minetest.register_on_respawnplayer(function(player)
    if voxsoul.world then
        voxsoul.world.setup_player(player)
    end
end)

minetest.register_on_joinplayer(function(player)
    minetest.after(1, function()
        if not player:is_player() then return end
        voxsoul.world.respawn_enemies()
        local sy = voxsoul.world.spawn_y()
        if not voxsoul.boss.is_defeated("tree_sentinel") then
            voxsoul.boss.spawn("tree_sentinel", vector.new(80, sy, 0))
        end
        if not voxsoul.boss.is_defeated("margit") then
            voxsoul.boss.spawn("margit", vector.new(160, sy, 0))
        end
        if not voxsoul.boss.is_defeated("grafted_hag") then
            voxsoul.boss.spawn("grafted_hag", vector.new(255, sy, 15))
        end
    end)
end)

minetest.register_node("voxsoul_world:tutorial_sign", {
    description = "Tutorial Sign",
    tiles = { "voxsoul_tutorial.png" },
    groups = { unbreakable = 1 },
    paramtype = "light",
    sunlight_propagates = true,
    on_rightclick = function(pos, node, clicker)
        if clicker:is_player() then
            minetest.chat_send_player(clicker:get_player_name(),
                "LMB=light | Shift+LMB=heavy | RMB=block | Space=jump | Space+move=dodge | E=grace | Z=lock-on")
        end
    end,
})

minetest.register_globalstep(function()
    for _, player in ipairs(minetest.get_connected_players()) do
        local ctrl = player:get_player_control()
        local pname = player:get_player_name()
        local edge = voxsoul.world._edge[pname] or {}

        if ctrl.dig and not edge.dig then
            if ctrl.sneak then
                voxsoul.combat.perform_attack(player, "heavy")
            else
                voxsoul.combat.perform_attack(player, "light")
            end
        end
        if ctrl.place and not edge.place then
            voxsoul.combat.start_block(player)
        elseif not ctrl.place and edge.place then
            voxsoul.combat.stop_block(player)
        end
        if ctrl.jump and not edge.jump and (ctrl.up or ctrl.down or ctrl.left or ctrl.right) then
            voxsoul.combat.dodge.try_start(player, voxsoul.combat.ensure_data(player))
        end
        if ctrl.aux1 and not edge.aux1 then
            if not voxsoul.grace.try_interact(player) then
                voxsoul.world.try_pickup_runes(player)
            end
        end
        if ctrl.zoom and not edge.zoom then
            voxsoul.combat.toggle_lockon(player)
        end

        edge.dig = ctrl.dig
        edge.place = ctrl.place
        edge.jump = ctrl.jump
        edge.aux1 = ctrl.aux1
        edge.zoom = ctrl.zoom
        voxsoul.world._edge[pname] = edge
    end
end)

minetest.register_chatcommand("lockon", {
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if player then voxsoul.combat.toggle_lockon(player) end
        return true
    end,
})

minetest.register_on_mods_loaded(function()
    minetest.register_alias("voxsoul:lockon", "lockon")
end)
