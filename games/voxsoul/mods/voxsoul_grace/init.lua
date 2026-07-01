voxsoul.grace = { sites = {} }

function voxsoul.grace.register(id, def)
    def.id = id
    voxsoul.grace.sites[id] = def
end

function voxsoul.grace.unlock(player, grace_id)
    local d = voxsoul.player.data[player:get_player_name()]
    d.graces[grace_id] = true
end

function voxsoul.grace.teleport_to_last_grace(player)
    local d = voxsoul.player.data[player:get_player_name()]
    local site = voxsoul.grace.sites[d.last_grace]
    if site then
        player:set_pos(site.pos)
    end
end

function voxsoul.grace.rest(player)
    local cd = voxsoul.combat.ensure_data(player)
    cd.hp = cd.max_hp
    cd.stamina = cd.max_stamina
    cd.state = "idle"
    if voxsoul.combat.sync_engine_hp then
        voxsoul.combat.sync_engine_hp(player)
    end
    if voxsoul.world and voxsoul.world.respawn_enemies then
        voxsoul.world.respawn_enemies()
    end
end

function voxsoul.grace.open_travel_menu(player)
    local d = voxsoul.player.data[player:get_player_name()]
    local form = "size[6,6;true]bgcolor[#120e0c;true]label[0,0;Travel — Sites of Grace]"
    local y = 1
    for id, site in pairs(voxsoul.grace.sites) do
        if d.graces[id] then
            form = form .. string.format("button[0,%f;6,1;%s;%s]", y, id, site.name)
            y = y + 1
        end
    end
    form = form .. "button[0,5;6,1;close;Close]"
    minetest.show_formspec(player:get_player_name(), "voxsoul:travel", form)
end

function voxsoul.grace.open_menu(player, grace_id)
    local form = "size[6,6;true]bgcolor[#120e0c;true]label[0,0;Site of Grace]" ..
        "button[0,1;6,1;rest;Rest]" ..
        "button[0,2;6,1;level;Level Up]" ..
        "button[0,3;6,1;travel;Travel]" ..
        "button[0,4;6,1;close;Leave]"
    minetest.show_formspec(player:get_player_name(), "voxsoul:grace:" .. grace_id, form)
end

function voxsoul.grace.try_interact(player)
    local pos = player:get_pos()
    for id, site in pairs(voxsoul.grace.sites) do
        if vector.distance(pos, site.pos) < 3 then
            voxsoul.grace.open_menu(player, id)
            return true
        end
    end
    return false
end

voxsoul.grace.register("gatefront", { name = "引导门前赐福", pos = vector.new(0, 20, 8), unlock = "default" })
voxsoul.grace.register("stormhill", { name = "风暴山头赐福", pos = vector.new(80, 20, -12), unlock = "proximity" })
voxsoul.grace.register("after_margit", { name = "雾墙门外赐福", pos = vector.new(170, 20, 5), unlock = "boss:margit" })
voxsoul.grace.register("stormveil_side", { name = "史东薇尔侧室赐福", pos = vector.new(210, 20, -25), unlock = "proximity" })
voxsoul.grace.register("stormveil_hall", { name = "接肢大厅赐福", pos = vector.new(235, 20, 8), unlock = "proximity" })

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname:find("^voxsoul:grace:") then
        if fields.rest then voxsoul.grace.rest(player) end
        if fields.level then voxsoul.player.open_upgrade_menu(player) end
        if fields.travel then voxsoul.grace.open_travel_menu(player) end
        return
    end
    if formname == "voxsoul:travel" and fields.close == nil then
        for id in pairs(fields) do
            local site = voxsoul.grace.sites[id]
            if site then
                player:set_pos(site.pos)
                local d = voxsoul.player.data[player:get_player_name()]
                d.last_grace = id
            end
        end
    end
end)

minetest.register_node("voxsoul_grace:site", {
    description = "Grace Site",
    tiles = { "voxsoul_grace.png" },
    groups = { unbreakable = 1 },
    paramtype = "light",
    sunlight_propagates = true,
    on_rightclick = function(pos, node, clicker)
        if clicker:is_player() then
            for id, site in pairs(voxsoul.grace.sites) do
                if vector.distance(pos, site.pos) < 1.5 or vector.distance(clicker:get_pos(), site.pos) < 3 then
                    voxsoul.grace.unlock(clicker, id)
                    local d = voxsoul.player.data[clicker:get_player_name()]
                    d.last_grace = id
                    voxsoul.grace.open_menu(clicker, id)
                    return
                end
            end
        end
    end,
})
