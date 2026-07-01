voxsoul.world = {}
voxsoul.world._edge = {}
voxsoul.world.enemy_spawns = {}

local modpath = minetest.get_modpath("voxsoul_world")
dofile(modpath .. "/nodes.lua")
dofile(modpath .. "/map_builder.lua")
dofile(modpath .. "/spawn.lua")

local SPAWN_Y = 11

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
        textures = { "voxsoul_enemy.png" },
        physical = true,
        collisionbox = { -0.4, 0, -0.4, 0.4, 1.8, 0.4 },
    },
    voxsoul_combatant = true,
    hp = 150,
    max_poise = 40,
    poise = 40,
    runes = 100,
    on_activate = function(self)
        self.object:set_armor_groups({ immortal = 1 })
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
        textures = { "voxsoul_enemy.png" },
        physical = true,
        collisionbox = { -0.4, 0, -0.4, 0.4, 1.5, 0.4 },
    },
    voxsoul_combatant = true,
    hp = 80,
    max_poise = 20,
    poise = 20,
    runes = 50,
    on_activate = function(self)
        self.object:set_armor_groups({ immortal = 1 })
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

local function register_spawn(pos, name)
    table.insert(voxsoul.world.enemy_spawns, { pos = pos, name = name, entity = nil })
end

minetest.register_on_mods_loaded(function()
    register_spawn(vector.new(50, SPAWN_Y, 5), "voxsoul_world:knight")
    register_spawn(vector.new(55, SPAWN_Y, -5), "voxsoul_world:knight")
    register_spawn(vector.new(210, 6, 45), "voxsoul_world:omen_freak")
    register_spawn(vector.new(215, 6, 50), "voxsoul_world:omen_freak")
    register_spawn(vector.new(220, 6, 55), "voxsoul_world:omen_freak")
end)

minetest.register_on_joinplayer(function(player)
    minetest.after(0, function()
        if not player:is_player() then
            return
        end
        voxsoul.world.setup_player(player)
        minetest.after(0.3, function()
            if player:is_player() and voxsoul.camera then
                voxsoul.camera.apply(player)
            end
        end)
    end)
    minetest.after(1, function()
        if not player:is_player() then return end
        voxsoul.world.respawn_enemies()
        if not voxsoul.boss.is_defeated("tree_sentinel") then
            voxsoul.boss.spawn("tree_sentinel", vector.new(80, SPAWN_Y, 0))
        end
        if not voxsoul.boss.is_defeated("margit") then
            voxsoul.boss.spawn("margit", vector.new(160, SPAWN_Y, 0))
        end
        if not voxsoul.boss.is_defeated("grafted_hag") then
            voxsoul.boss.spawn("grafted_hag", vector.new(230, 6, 50))
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
                "LMB=light attack | Shift+LMB=heavy | RMB=block | Space+dodge | E=grace | Q=lock-on")
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
            voxsoul.grace.try_interact(player)
        end

        edge.dig = ctrl.dig
        edge.place = ctrl.place
        edge.jump = ctrl.jump
        edge.aux1 = ctrl.aux1
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
