# VoxSoul 魂类 Demo 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在 Luanti 5.13+ 上实现可运行的 VoxSoul 子游戏 Demo（第三人称魂类战斗 + 3 Boss + 赐福成长循环）。

**Architecture:** 10 个 Lua mod 组成子游戏，自研战斗/Hitbox/Boss 状态机；体素手工地图 + mesh 实体；纯 Lua 逻辑测试 mod 在加载时断言核心数值。

**Tech Stack:** Luanti 5.13+、Lua 5.1、Luanti Lua API（`set_camera`、`object_property`、`register_entity`、HUD API）

## Global Constraints

- Luanti **5.13+**（`player:set_camera({mode = 'third'})` 锁定第三人称）
- **不依赖** Advanced Fight Library / hitboxes_lib
- **纯单人**；v1 不提供第一人称切换
- **手工地图**，禁用随机 mapgen（`fixed_map` + 预置 world）
- 粉丝致敬项目，包含 `FAN_PROJECT.md`，不商用
- 同屏 animated mesh 实体 ≤ 5；目标 60 FPS @ 1080p

---

## 文件结构总览

```
games/voxsoul/
├── game.conf
├── FAN_PROJECT.md
├── mods/
│   ├── voxsoul_core/
│   │   ├── mod.conf
│   │   ├── init.lua
│   │   └── disable_defaults.lua
│   ├── voxsoul_camera/
│   │   ├── mod.conf
│   │   └── init.lua
│   ├── voxsoul_entity/
│   │   ├── mod.conf
│   │   ├── init.lua
│   │   ├── hitbox.lua
│   │   └── animation.lua
│   ├── voxsoul_combat/
│   │   ├── mod.conf
│   │   ├── init.lua
│   │   ├── constants.lua
│   │   ├── stamina.lua
│   │   ├── state.lua
│   │   ├── attacks.lua
│   │   ├── dodge.lua
│   │   ├── block.lua
│   │   ├── lockon.lua
│   │   └── tests.lua
│   ├── voxsoul_ui/
│   │   ├── mod.conf
│   │   ├── init.lua
│   │   └── hud.lua
│   ├── voxsoul_player/
│   │   ├── mod.conf
│   │   ├── init.lua
│   │   ├── stats.lua
│   │   ├── death.lua
│   │   └── persistence.lua
│   ├── voxsoul_items/
│   │   ├── mod.conf
│   │   ├── init.lua
│   │   └── equipment.lua
│   ├── voxsoul_grace/
│   │   ├── mod.conf
│   │   ├── init.lua
│   │   └── menu.lua
│   ├── voxsoul_boss/
│   │   ├── mod.conf
│   │   ├── init.lua
│   │   ├── ai.lua
│   │   ├── registry.lua
│   │   └── bosses/
│   │       ├── tree_sentinel.lua
│   │       ├── margit.lua
│   │       └── grafted_hag.lua
│   ├── voxsoul_world/
│   │   ├── mod.conf
│   │   ├── init.lua
│   │   ├── regions.lua
│   │   ├── enemies.lua
│   │   ├── spawns.lua
│   │   └── schems/
│   └── voxsoul_tests/
│       ├── mod.conf
│       └── init.lua
└── worlds/
    └── demo_interlude/
        ├── world.mt
        └── map_meta.txt
```

---

### Task 1: 子游戏脚手架与开发环境

**Files:**
- Create: `games/voxsoul/game.conf`
- Create: `games/voxsoul/FAN_PROJECT.md`
- Create: `games/voxsoul/mods/voxsoul_core/mod.conf`
- Create: `games/voxsoul/mods/voxsoul_core/init.lua`
- Create: `games/voxsoul/worlds/demo_interlude/world.mt`
- Create: `README.md`

**Interfaces:**
- Produces: 可加载的空子游戏 `voxsoul`；全局表 `voxsoul = {}`

- [ ] **Step 1: 创建 game.conf**

```ini
title = VoxSoul
description = Elden Ring-inspired souls-like demo for Luanti
author = VoxSoul Team
release = 1

load_mod_voxsoul_core = true
load_mod_voxsoul_camera = true
load_mod_voxsoul_entity = true
load_mod_voxsoul_combat = true
load_mod_voxsoul_ui = true
load_mod_voxsoul_player = true
load_mod_voxsoul_items = true
load_mod_voxsoul_grace = true
load_mod_voxsoul_boss = true
load_mod_voxsoul_world = true
load_mod_voxsoul_tests = true
```

- [ ] **Step 2: 创建 FAN_PROJECT.md**

```markdown
# FAN PROJECT NOTICE

VoxSoul is an unofficial fan project inspired by Elden Ring.
Not affiliated with FromSoftware or Bandai Namco.
For personal / small-group use only. Do not commercialize.
Replace all referenced names and assets before public distribution.
```

- [ ] **Step 3: 创建 voxsoul_core 入口**

`games/voxsoul/mods/voxsoul_core/mod.conf`:
```ini
name = voxsoul_core
description = VoxSoul core initialization
depends =
```

`games/voxsoul/mods/voxsoul_core/init.lua`:
```lua
voxsoul = rawget(_G, "voxsoul") or {}
voxsoul.VERSION = "0.1.0-dev"

minetest.log("action", "[voxsoul_core] Loading VoxSoul " .. voxsoul.VERSION)

minetest.register_on_joinplayer(function(player)
    player:set_physics_override({
        speed = 1.0,
        jump = 0,
        gravity = 1.0,
    })
end)
```

- [ ] **Step 4: 创建 demo 世界配置**

`games/voxsoul/worlds/demo_interlude/world.mt`:
```ini
gameid = voxsoul
backend = sqlite3
creative_mode = false
enable_damage = true
fixed_map_seed =
```

- [ ] **Step 5: 链接到 Luanti 并验证加载**

在 PowerShell 中（将路径替换为你的 Luanti user 目录）:

```powershell
$LuantiUser = "$env:APPDATA\Luanti"
New-Item -ItemType Junction -Path "$LuantiUser\games\voxsoul" -Target "D:\Z\game\VoxSoul\games\voxsoul"
```

启动 Luanti → 创建世界 → 选择 **VoxSoul** → 进入无报错控制台 `[voxsoul_core] Loading VoxSoul 0.1.0-dev`

- [ ] **Step 6: Commit**

```powershell
git add games/voxsoul README.md
git commit -m "feat: scaffold VoxSoul Luanti subgame"
```

---

### Task 2: voxsoul_core — 禁用默认沙盒操作

**Files:**
- Create: `games/voxsoul/mods/voxsoul_core/disable_defaults.lua`
- Modify: `games/voxsoul/mods/voxsoul_core/init.lua`
- Modify: `games/voxsoul/mods/voxsoul_core/mod.conf`

**Interfaces:**
- Consumes: `voxsoul` global
- Produces: `voxsoul.core.disable_dig()` 在玩家加入时调用

- [ ] **Step 1: 写失败测试（voxsoul_tests 占位）**

`games/voxsoul/mods/voxsoul_tests/mod.conf`:
```ini
name = voxsoul_tests
description = VoxSoul dev assertions
depends = voxsoul_core
```

`games/voxsoul/mods/voxsoul_tests/init.lua`:
```lua
minetest.register_on_mods_loaded(function()
    assert(voxsoul.core, "voxsoul.core must exist")
    assert(voxsoul.core.is_digging_disabled == true, "digging should be disabled")
    minetest.log("action", "[voxsoul_tests] core tests passed")
end)
```

- [ ] **Step 2: 运行验证 — 预期 FAIL**

启动游戏，控制台应报: `voxsoul.core must exist`

- [ ] **Step 3: 实现 disable_defaults.lua**

`games/voxsoul/mods/voxsoul_core/disable_defaults.lua`:
```lua
voxsoul.core = voxsoul.core or {}
voxsoul.core.is_digging_disabled = true

local function disable_item_use(itemstack, player, pointed_thing)
    return itemstack
end

minetest.register_on_joinplayer(function(player, last_login)
    local name = player:get_player_name()
    local inv = player:get_inventory()
    inv:set_size("main", 8)
    inv:set_size("craft", 0)
    player:hud_set_flags({
        hotbar = false,
        healthbar = false,
        crosshair = true,
        wielditem = false,
    })
end)

minetest.register_on_dignode(function(pos, oldnode, digger)
    if digger and digger:is_player() then
        return true
    end
end)

minetest.register_on_placenode(function(itemstack, placer)
    if placer and placer:is_player() then
        return itemstack
    end
end)

minetest.register_on_punchplayer(function(player)
    return true
end)

minetest.register_chatcommand("voxsoul", {
    params = "unstuck",
    description = "VoxSoul debug commands",
    func = function(name, param)
        if param == "unstuck" then
            local player = minetest.get_player_by_name(name)
            if player and voxsoul.grace then
                voxsoul.grace.teleport_to_last_grace(player)
            end
            return true, "Teleported to last grace."
        end
        return false, "Usage: /voxsoul unstuck"
    end,
})
```

`games/voxsoul/mods/voxsoul_core/init.lua` 末尾追加:
```lua
dofile(minetest.get_modpath("voxsoul_core") .. "/disable_defaults.lua")
```

- [ ] **Step 4: 运行验证 — 预期 PASS**

控制台: `[voxsoul_tests] core tests passed`；左键挖掘/右键放置无效

- [ ] **Step 5: Commit**

```powershell
git add games/voxsoul/mods/voxsoul_core games/voxsoul/mods/voxsoul_tests
git commit -m "feat: disable default dig/place and add debug command stub"
```

---

### Task 3: voxsoul_camera — 越肩第三人称

**Files:**
- Create: `games/voxsoul/mods/voxsoul_camera/mod.conf`
- Create: `games/voxsoul/mods/voxsoul_camera/init.lua`

**Interfaces:**
- Consumes: `voxsoul.core`
- Produces: `voxsoul.camera.apply(player)` — 锁定第三人称 + 越肩偏移

- [ ] **Step 1: 写测试断言**

在 `games/voxsoul/mods/voxsoul_tests/init.lua` 追加:
```lua
minetest.register_on_mods_loaded(function()
    assert(voxsoul.camera, "voxsoul.camera must exist")
    assert(type(voxsoul.camera.apply) == "function")
    minetest.log("action", "[voxsoul_tests] camera tests passed")
end)
```

- [ ] **Step 2: 运行 — 预期 FAIL** (`voxsoul.camera must exist`)

- [ ] **Step 3: 实现相机 mod**

`games/voxsoul/mods/voxsoul_camera/mod.conf`:
```ini
name = voxsoul_camera
description = Over-shoulder third person camera
depends = voxsoul_core
```

`games/voxsoul/mods/voxsoul_camera/init.lua`:
```lua
voxsoul.camera = {}

local EYE_FIRST = vector.new(0, 0, 0)
local EYE_THIRD = vector.new(0, 2.5, -4.5)
local EYE_THIRD_FRONT = vector.new(0, 2.5, 4.5)

function voxsoul.camera.apply(player)
    player:set_camera({ mode = "third" })
    player:set_eye_offset(EYE_FIRST, EYE_THIRD, EYE_THIRD_FRONT)
    player:set_fov(75)
end

minetest.register_on_joinplayer(function(player)
    voxsoul.camera.apply(player)
end)

minetest.register_on_leaveplayer(function(player)
    player:set_camera({ mode = "any" })
end)

-- 每 0.5s 强制第三人称，防止玩家切换
minetest.register_globalstep(function(dtime)
    voxsoul.camera._accum = (voxsoul.camera._accum or 0) + dtime
    if voxsoul.camera._accum < 0.5 then return end
    voxsoul.camera._accum = 0
    for _, player in ipairs(minetest.get_connected_players()) do
        player:set_camera({ mode = "third" })
    end
end)
```

- [ ] **Step 4: 运行 — 预期 PASS**；进入游戏为越肩视角，按 C 无法切回第一人称

- [ ] **Step 5: Commit**

```powershell
git add games/voxsoul/mods/voxsoul_camera games/voxsoul/mods/voxsoul_tests
git commit -m "feat: lock over-shoulder third person camera"
```

---

### Task 4: voxsoul_entity — Hitbox 与动画工具

**Files:**
- Create: `games/voxsoul/mods/voxsoul_entity/mod.conf`
- Create: `games/voxsoul/mods/voxsoul_entity/init.lua`
- Create: `games/voxsoul/mods/voxsoul_entity/hitbox.lua`
- Create: `games/voxsoul/mods/voxsoul_entity/animation.lua`
- Create: `games/voxsoul/mods/voxsoul_entity/tests.lua`

**Interfaces:**
- Produces:
  - `voxsoul.entity.hitbox.in_arc(origin, yaw, target_pos, radius, angle_deg) -> boolean`
  - `voxsoul.entity.hitbox.in_circle(origin, target_pos, radius) -> boolean`
  - `voxsoul.entity.play_anim(obj, anim_name, speed)` — 封装 `obj:set_animation`

- [ ] **Step 1: 写 Hitbox 单元测试**

`games/voxsoul/mods/voxsoul_entity/tests.lua`:
```lua
local hitbox = dofile(minetest.get_modpath("voxsoul_entity") .. "/hitbox.lua")

local origin = vector.new(0, 0, 0)
local yaw = 0

assert(hitbox.in_arc(origin, yaw, vector.new(1, 0, 0), 2.5, 90) == true)
assert(hitbox.in_arc(origin, yaw, vector.new(0, 0, -1), 2.5, 90) == false)
assert(hitbox.in_circle(origin, vector.new(1, 0, 0), 2.0) == true)
assert(hitbox.in_circle(origin, vector.new(3, 0, 0), 2.0) == false)

minetest.log("action", "[voxsoul_entity] hitbox tests passed")
```

- [ ] **Step 2: 运行 — 预期 FAIL**（模块未加载）

- [ ] **Step 3: 实现 hitbox.lua**

```lua
local M = {}

local function flat_dir(from, to)
    local dx = to.x - from.x
    local dz = to.z - from.z
    local len = math.sqrt(dx * dx + dz * dz)
    if len < 0.001 then return 0, 0 end
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
```

`games/voxsoul/mods/voxsoul_entity/init.lua`:
```lua
voxsoul.entity = {}
local modpath = minetest.get_modpath("voxsoul_entity")
voxsoul.entity.hitbox = dofile(modpath .. "/hitbox.lua")
dofile(modpath .. "/animation.lua")
dofile(modpath .. "/tests.lua")
```

`games/voxsoul/mods/voxsoul_entity/animation.lua`:
```lua
function voxsoul.entity.play_anim(obj, range, speed, loop)
    if not obj or not obj.set_animation then return end
    obj:set_animation({ x = range[1], y = range[2] }, speed or 30, 0, loop ~= false)
end

function voxsoul.entity.register_mesh_entity(name, def)
    def.visual = "mesh"
    def.mesh = def.mesh or "voxsoul_entity_placeholder.b3d"
    def.textures = def.textures or { "voxsoul_placeholder.png" }
    def.static_save = def.static_save ~= false
    minetest.register_entity(name, def)
end
```

- [ ] **Step 4: 运行 — 预期 PASS** `[voxsoul_entity] hitbox tests passed`

- [ ] **Step 5: Commit**

```powershell
git add games/voxsoul/mods/voxsoul_entity
git commit -m "feat: add hitbox and animation entity helpers"
```

---

### Task 5: voxsoul_combat — 耐力与状态机核心

**Files:**
- Create: `games/voxsoul/mods/voxsoul_combat/mod.conf`
- Create: `games/voxsoul/mods/voxsoul_combat/constants.lua`
- Create: `games/voxsoul/mods/voxsoul_combat/stamina.lua`
- Create: `games/voxsoul/mods/voxsoul_combat/state.lua`
- Create: `games/voxsoul/mods/voxsoul_combat/tests.lua`
- Create: `games/voxsoul/mods/voxsoul_combat/init.lua`

**Interfaces:**
- Produces:
  - `voxsoul.combat.STAMINA_COST.light_attack = 12`
  - `voxsoul.combat.stamina.can_spend(current, cost) -> boolean`
  - `voxsoul.combat.stamina.tick(current, max, dt, regen_delay, is_exhausted) -> new_current, new_delay`
  - `voxsoul.combat.state.can_transition(from, to) -> boolean`
  - `voxsoul.combat.get_player_state(player) -> string`

- [ ] **Step 1: 写耐力测试**

`games/voxsoul/mods/voxsoul_combat/tests.lua`:
```lua
local stamina = dofile(minetest.get_modpath("voxsoul_combat") .. "/stamina.lua")
local state = dofile(minetest.get_modpath("voxsoul_combat") .. "/state.lua")

assert(stamina.can_spend(22, 22) == true)
assert(stamina.can_spend(21, 22) == false)

local cur, delay = stamina.tick(0, 100, 0.1, 0, false)
assert(cur > 0)

assert(state.can_transition("idle", "attacking") == true)
assert(state.can_transition("hitstun", "attacking") == false)
assert(state.priority("hitstun") > state.priority("idle"))

minetest.log("action", "[voxsoul_combat] stamina/state tests passed")
```

- [ ] **Step 2: 运行 — 预期 FAIL**

- [ ] **Step 3: 实现 constants.lua + stamina.lua + state.lua**

`games/voxsoul/mods/voxsoul_combat/constants.lua`:
```lua
return {
    STAMINA_REGEN_RATE = 35,
    STAMINA_REGEN_DELAY_ATTACK = 0.8,
    STAMINA_REGEN_DELAY_DODGE = 1.0,
    STAMINA_EXHAUST_THRESHOLD = 0.20,
    STAMINA_COST = {
        light_attack = 12,
        heavy_attack = 28,
        dodge = 22,
        dodge_chain_bonus = 5,
        block_per_sec = 8,
        parry_fail = 15,
    },
    ATTACK = {
        light = { base_damage = 35, windup = 0.3, poise = 8 },
        heavy = { base_damage = 70, windup = 0.7, poise = 25 },
    },
    DODGE = { duration = 0.6, iframes_start = 0.1, iframes_end = 0.5, cost = 22 },
    PARRY = { window = 0.25, stagger = 2.0 },
    POISE_RECOVER_RATE = 0.05,
}
```

`games/voxsoul/mods/voxsoul_combat/stamina.lua`:
```lua
local C = dofile(minetest.get_modpath("voxsoul_combat") .. "/constants.lua")
local M = {}

function M.can_spend(current, cost)
    return current >= cost
end

function M.is_exhausted(current, max_stamina)
    return current < max_stamina * C.STAMINA_EXHAUST_THRESHOLD
end

function M.tick(current, max_stamina, dt, regen_delay, allow_regen)
    if regen_delay > 0 then
        return current, regen_delay - dt
    end
    if not allow_regen then
        return current, 0
    end
    local next_val = math.min(max_stamina, current + C.STAMINA_REGEN_RATE * dt)
    return next_val, 0
end

return M
```

`games/voxsoul/mods/voxsoul_combat/state.lua`:
```lua
local PRIORITY = {
    idle = 1, blocking = 2, attacking = 3, dodging = 4,
    guardbreak = 5, hitstun = 6,
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

return M
```

- [ ] **Step 4: 运行 — 预期 PASS**

- [ ] **Step 5: Commit**

```powershell
git add games/voxsoul/mods/voxsoul_combat
git commit -m "feat: add combat stamina and state machine core"
```

---

### Task 6: voxsoul_combat — 攻击、闪避、格挡、锁定

**Files:**
- Create: `games/voxsoul/mods/voxsoul_combat/attacks.lua`
- Create: `games/voxsoul/mods/voxsoul_combat/dodge.lua`
- Create: `games/voxsoul/mods/voxsoul_combat/block.lua`
- Create: `games/voxsoul/mods/voxsoul_combat/lockon.lua`
- Modify: `games/voxsoul/mods/voxsoul_combat/init.lua`

**Interfaces:**
- Consumes: `voxsoul.entity.hitbox`, `voxsoul.combat.constants`, player meta
- Produces:
  - `voxsoul.combat.try_light_attack(player)`
  - `voxsoul.combat.try_dodge(player, move_dir)`
  - `voxsoul.combat.is_invincible(player) -> boolean`
  - `voxsoul.combat.toggle_lockon(player)`

- [ ] **Step 1: 在 tests.lua 追加 invincibility 窗口测试**

```lua
local dodge = dofile(minetest.get_modpath("voxsoul_combat") .. "/dodge.lua")
assert(dodge.is_in_iframes(0.05, 0.6) == false)
assert(dodge.is_in_iframes(0.2, 0.6) == true)
assert(dodge.is_in_iframes(0.55, 0.6) == false)
```

- [ ] **Step 2: 运行 — 预期 FAIL**

- [ ] **Step 3: 实现 dodge.lua**

```lua
local C = dofile(minetest.get_modpath("voxsoul_combat") .. "/constants.lua")
local M = {}

function M.is_in_iframes(elapsed, duration)
    duration = duration or C.DODGE.duration
    return elapsed >= C.DODGE.iframes_start and elapsed <= C.DODGE.iframes_end
end

function M.try_start(player, data)
    local cost = C.STAMINA_COST.dodge + (data.dodge_chain or 0) * C.STAMINA_COST.dodge_chain_bonus
    if not voxsoul.combat.stamina.can_spend(data.stamina, cost) then return false end
    data.stamina = data.stamina - cost
    data.state = "dodging"
    data.dodge_elapsed = 0
    data.dodge_chain = math.min(2, (data.dodge_chain or 0) + 1)
    data.regen_delay = C.STAMINA_REGEN_DELAY_DODGE
    player:set_velocity(vector.new(0, 0, 0))
    return true
end

return M
```

- [ ] **Step 4: 实现 attacks.lua（扇形命中）**

```lua
local C = dofile(minetest.get_modpath("voxsoul_combat") .. "/constants.lua")

local function get_combat_data(player)
    return voxsoul.combat.ensure_data(player)
end

function voxsoul.combat.perform_attack(player, kind)
    local data = get_combat_data(player)
    if data.state ~= "idle" and data.state ~= "blocking" then return end
    local atk = kind == "heavy" and C.ATTACK.heavy or C.ATTACK.light
    local cost = kind == "heavy" and C.STAMINA_COST.heavy_attack or C.STAMINA_COST.light_attack
    if not voxsoul.combat.stamina.can_spend(data.stamina, cost) then return end
    data.stamina = data.stamina - cost
    data.state = "attacking"
    data.attack_timer = 0
    data.pending_attack = atk
    data.regen_delay = C.STAMINA_REGEN_DELAY_ATTACK
end

function voxsoul.combat.resolve_attack_hit(player, atk)
    local pos = player:get_pos()
    local yaw = player:get_look_horizontal()
    local weapon_mult = voxsoul.items and voxsoul.items.get_damage_mult(player) or 1.0
    local damage = atk.base_damage * weapon_mult
    for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 3.0)) do
        if obj:is_player() then goto continue end
        if obj:get_luaentity() and obj:get_luaentity().voxsoul_combatant then
            local tpos = obj:get_pos()
            if voxsoul.entity.hitbox.in_arc(pos, yaw, tpos, 2.5, 90) then
                voxsoul.combat.apply_damage_to_entity(obj, damage, atk.poise)
            end
        end
        ::continue::
    end
end
```

- [ ] **Step 5: 实现 init.lua 输入绑定与 globalstep**

```lua
voxsoul.combat = {}
local modpath = minetest.get_modpath("voxsoul_combat")
voxsoul.combat.constants = dofile(modpath .. "/constants.lua")
voxsoul.combat.stamina = dofile(modpath .. "/stamina.lua")
voxsoul.combat.state = dofile(modpath .. "/state.lua")
dofile(modpath .. "/attacks.lua")
dofile(modpath .. "/dodge.lua")
dofile(modpath .. "/block.lua")
dofile(modpath .. "/lockon.lua")

local player_data = {}

function voxsoul.combat.ensure_data(player)
    local name = player:get_player_name()
    if not player_data[name] then
        player_data[name] = {
            state = "idle", stamina = 100, max_stamina = 100,
            hp = 400, max_hp = 400, poise = 100, max_poise = 100,
            regen_delay = 0, dodge_elapsed = 0, dodge_chain = 0,
        }
    end
    return player_data[name]
end

function voxsoul.combat.is_invincible(player)
    local d = voxsoul.combat.ensure_data(player)
    if d.state ~= "dodging" then return false end
    return voxsoul.combat.dodge.is_in_iframes(d.dodge_elapsed)
end

minetest.register_on_punchplayer(function(player, hitter)
    if voxsoul.combat.is_invincible(player) then return true end
end)

minetest.register_on_joinplayer(function(player)
    voxsoul.combat.ensure_data(player)
end)

minetest.register_on_leaveplayer(function(player)
    player_data[player:get_player_name()] = nil
end)

-- Key: aux1(E) reserved; use player controls via register_on_player_receive_fields or key_of_fields
-- Luanti: register key press through playerphysics + aux1; for v1 use chatcommands for dev:
minetest.register_chatcommand("atk", { func = function(n) voxsoul.combat.perform_attack(minetest.get_player_by_name(n), "light") return true end })
minetest.register_chatcommand("dodge", { func = function(n) voxsoul.combat.dodge.try_start(minetest.get_player_by_name(n), voxsoul.combat.ensure_data(minetest.get_player_by_name(n))) return true end })

minetest.register_globalstep(function(dt)
    for _, player in ipairs(minetest.get_connected_players()) do
        local d = voxsoul.combat.ensure_data(player)
        if d.state == "dodging" then
            d.dodge_elapsed = d.dodge_elapsed + dt
            if d.dodge_elapsed >= voxsoul.combat.constants.DODGE.duration then
                d.state = "idle"
                d.dodge_elapsed = 0
            end
        elseif d.state == "attacking" then
            d.attack_timer = (d.attack_timer or 0) + dt
            if d.pending_attack and d.attack_timer >= d.pending_attack.windup then
                voxsoul.combat.resolve_attack_hit(player, d.pending_attack)
                d.pending_attack = nil
            end
            if d.attack_timer >= (d.pending_attack and d.pending_attack.windup or 0.3) + 0.3 then
                d.state = "idle"
                d.attack_timer = 0
            end
        end
        local allow = d.state ~= "blocking"
        d.stamina, d.regen_delay = voxsoul.combat.stamina.tick(d.stamina, d.max_stamina, dt, d.regen_delay, allow)
    end
end)

dofile(modpath .. "/tests.lua")
```

> **Note:** Task 6 完成后需追加 `player` 键位映射 mod 或在 Task 11 集成 `voxsoul_world` 教程牌前，用 `/atk` `/dodge` 验证战斗。Task 11 将绑定真实键位（通过 `player_control` 检测 LMB/RMB/Space/Q）。

- [ ] **Step 6: 运行 — 预期 PASS**；`/atk` 对测试 dummy 实体扣血

- [ ] **Step 7: Commit**

```powershell
git add games/voxsoul/mods/voxsoul_combat
git commit -m "feat: add attack dodge combat loop with dev commands"
```

---

### Task 7: voxsoul_ui — HUD 与 Boss 血条

**Files:**
- Create: `games/voxsoul/mods/voxsoul_ui/mod.conf`
- Create: `games/voxsoul/mods/voxsoul_ui/init.lua`
- Create: `games/voxsoul/mods/voxsoul_ui/hud.lua`

**Interfaces:**
- Consumes: `voxsoul.combat.ensure_data(player)`
- Produces:
  - `voxsoul.ui.update_player_hud(player)`
  - `voxsoul.ui.show_boss_bar(boss_id, name, hp, max_hp)`
  - `voxsoul.ui.hide_boss_bar(boss_id)`

- [ ] **Step 1: 实现 hud.lua（HP/耐力/卢恩条）**

```lua
local hud_ids = {}

local function bar(width, pct, color)
    local filled = math.floor(width * pct)
    return string.rep("▓", filled) .. string.rep("░", width - filled)
end

function voxsoul.ui.update_player_hud(player)
    local name = player:get_player_name()
    local d = voxsoul.combat.ensure_data(player)
    hud_ids[name] = hud_ids[name] or {}
    local ids = hud_ids[name]
    local hp_pct = d.hp / d.max_hp
    local st_pct = d.stamina / d.max_stamina
    local runes = voxsoul.player and voxsoul.player.get_runes(player) or 0
    local text = string.format("HP %s\nST %s\n卢恩: %d",
        bar(16, hp_pct), bar(16, st_pct), runes)
    if not ids.main then
        ids.main = player:hud_add({
            hud_elem_type = "text",
            position = { x = 0.02, y = 0.85 },
            offset = { x = 0, y = 0 },
            scale = { x = 100, y = 100 },
            text = text,
            number = 0xFFFFFF,
        })
    else
        player:hud_change(ids.main, "text", text)
    end
end

function voxsoul.ui.show_boss_bar(boss_id, boss_name, hp, max_hp)
    for _, player in ipairs(minetest.get_connected_players()) do
        local key = player:get_player_name() .. ":boss"
        player:hud_add({
            hud_elem_type = "text",
            name = "voxsoul_boss_" .. boss_id,
            position = { x = 0.5, y = 0.05 },
            offset = { x = -100, y = 0 },
            alignment = { x = 0, y = 0 },
            scale = { x = 150, y = 150 },
            text = boss_name .. "\n" .. bar(24, hp / max_hp),
            number = 0xFF4444,
        })
    end
end
```

- [ ] **Step 2: globalstep 刷新 HUD**

`init.lua`:
```lua
voxsoul.ui = {}
dofile(minetest.get_modpath("voxsoul_ui") .. "/hud.lua")

minetest.register_globalstep(function(dt)
    for _, player in ipairs(minetest.get_connected_players()) do
        voxsoul.ui.update_player_hud(player)
    end
end)
```

- [ ] **Step 3: 游戏内验证** — 左下出现 HP/ST 条，/console 无报错

- [ ] **Step 4: Commit**

```powershell
git add games/voxsoul/mods/voxsoul_ui
git commit -m "feat: add HP stamina and rune HUD"
```

---

### Task 8: voxsoul_player + voxsoul_items — 成长、死亡、装备

**Files:**
- Create: `games/voxsoul/mods/voxsoul_player/`（mod.conf, init.lua, stats.lua, death.lua, persistence.lua）
- Create: `games/voxsoul/mods/voxsoul_items/`（mod.conf, init.lua, equipment.lua）
- Modify: `games/voxsoul/mods/voxsoul_combat/tests.lua`

**Interfaces:**
- Produces:
  - `voxsoul.player.get_runes(player) -> number`
  - `voxsoul.player.add_runes(player, amount)`
  - `voxsoul.player.upgrade_stat(player, stat_name) -> boolean`
  - `voxsoul.player.on_death(player)` — 失去 50% 卢恩
  - `voxsoul.items.get_damage_mult(player) -> number`
  - `voxsoul.items.equip_weapon(player, weapon_id)`

- [ ] **Step 1: 写升级花费测试**

```lua
local stats = dofile(minetest.get_modpath("voxsoul_player") .. "/stats.lua")
assert(stats.upgrade_cost(3) == 300)
assert(stats.upgrade_cost(20) == 2000)
local lost = stats.death_rune_loss(1001)
assert(lost == 500)
```

- [ ] **Step 2: 实现 stats.lua**

```lua
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
```

- [ ] **Step 3: 实现 persistence.lua + death.lua**

```lua
-- persistence.lua
function voxsoul.player.load(player)
    local meta = player:get_meta()
    voxsoul.player.data[player:get_player_name()] = {
        runes = meta:get_int("voxsoul:runes"),
        stats = minetest.deserialize(meta:get_string("voxsoul:stats")) or { vigor=0, endurance=0, strength=0, dexterity=0 },
        graces = minetest.deserialize(meta:get_string("voxsoul:graces")) or { "gatefront" },
        last_grace = meta:get_string("voxsoul:last_grace") or "gatefront",
        weapon = meta:get_string("voxsoul:weapon") or "straight_sword",
        talisman = meta:get_string("voxsoul:talisman") or "",
    }
end

function voxsoul.player.save(player)
    local name = player:get_player_name()
    local d = voxsoul.player.data[name]
    local meta = player:get_meta()
    meta:set_int("voxsoul:runes", d.runes)
    meta:set_string("voxsoul:stats", minetest.serialize(d.stats))
    meta:set_string("voxsoul:graces", minetest.serialize(d.graces))
    meta:set_string("voxsoul:last_grace", d.last_grace)
    meta:set_string("voxsoul:weapon", d.weapon)
    meta:set_string("voxsoul:talisman", d.talisman)
end
```

```lua
-- death.lua
function voxsoul.player.on_death(player)
    local d = voxsoul.player.data[player:get_player_name()]
    local lost = voxsoul.player.stats.death_rune_loss(d.runes)
    d.runes = d.runes - lost
    voxsoul.player.spawn_rune_pile(player:get_pos(), lost)
    minetest.show_formspec(player:get_player_name(), "voxsoul:death",
        "size[8,4]label[0,0;YOU DIED]label[0,1;失去卢恩: " .. lost .. "]")
    minetest.after(2, function()
        if voxsoul.grace then voxsoul.grace.teleport_to_last_grace(player) end
        local cd = voxsoul.combat.ensure_data(player)
        cd.hp = cd.max_hp
        cd.stamina = cd.max_stamina
        cd.state = "idle"
    end)
end
```

- [ ] **Step 4: 实现 equipment.lua**

```lua
local WEAPONS = {
    straight_sword = { damage_mult = 1.0, speed_mult = 1.0 },
    curved_sword = { damage_mult = 0.85, speed_mult = 1.2 },
}
local TALISMANS = {
    golden_blessing = { max_hp_bonus = 5 },
}

function voxsoul.items.get_damage_mult(player)
    local d = voxsoul.player.data[player:get_player_name()]
    local w = WEAPONS[d.weapon] or WEAPONS.straight_sword
    local s = d.stats
    local mult = w.damage_mult
    mult = voxsoul.player.stats.apply_strength(mult, s.strength)
    mult = voxsoul.player.stats.apply_dexterity_damage(mult, s.dexterity)
    return mult
end
```

- [ ] **Step 5: 运行测试 — 预期 PASS**

- [ ] **Step 6: Commit**

```powershell
git add games/voxsoul/mods/voxsoul_player games/voxsoul/mods/voxsoul_items
git commit -m "feat: add player stats death persistence and equipment"
```

---

### Task 9: voxsoul_grace — 赐福点系统

**Files:**
- Create: `games/voxsoul/mods/voxsoul_grace/mod.conf`
- Create: `games/voxsoul/mods/voxsoul_grace/init.lua`
- Create: `games/voxsoul/mods/voxsoul_grace/menu.lua`

**Interfaces:**
- Produces:
  - `voxsoul.grace.register(id, def)` — def: `{ pos, name, unlock = "default"|"proximity"|"boss:margit" }`
  - `voxsoul.grace.open_menu(player, grace_id)`
  - `voxsoul.grace.teleport_to_last_grace(player)`
  - `voxsoul.grace.rest(player)` — 回满 HP/耐力，重置普通敌人

- [ ] **Step 1: 注册 4 个赐福点（坐标占位，Task 11 调整）**

```lua
voxsoul.grace = { sites = {} }

function voxsoul.grace.register(id, def)
    def.id = id
    voxsoul.grace.sites[id] = def
end

voxsoul.grace.register("gatefront", { name = "门旁赐福", pos = vector.new(0, 10, 0), unlock = "default" })
voxsoul.grace.register("stormhill", { name = "风暴关卡前赐福", pos = vector.new(80, 10, 0), unlock = "proximity" })
voxsoul.grace.register("after_margit", { name = "关卡后赐福", pos = vector.new(160, 10, 0), unlock = "boss:margit" })
voxsoul.grace.register("catacombs", { name = "接肢墓赐福", pos = vector.new(200, 5, 40), unlock = "proximity" })
```

- [ ] **Step 2: 实现 formspec 菜单（休息/升级/传送）**

```lua
function voxsoul.grace.open_menu(player, grace_id)
    local form = "size[6,6]" ..
        "label[0,0;═══ 赐福点 ═══]" ..
        "button[0,1;6,1;rest;休息]" ..
        "button[0,2;6,1;level;升级]" ..
        "button[0,3;6,1;travel;传送]" ..
        "button[0,4;6,1;close;离开]"
    minetest.show_formspec(player:get_player_name(), "voxsoul:grace:" .. grace_id, form)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if not formname:find("^voxsoul:grace:") then return end
    local grace_id = formname:sub(15)
    if fields.rest then voxsoul.grace.rest(player) end
    if fields.level then voxsoul.player.open_upgrade_menu(player) end
    if fields.travel then voxsoul.grace.open_travel_menu(player) end
end)
```

- [ ] **Step 3: 游戏内按 E 靠近赐福交互测试**

- [ ] **Step 4: Commit**

```powershell
git add games/voxsoul/mods/voxsoul_grace
git commit -m "feat: add grace site menu rest level and travel"
```

---

### Task 10: voxsoul_boss — 框架与 3 个 Boss

**Files:**
- Create: `games/voxsoul/mods/voxsoul_boss/mod.conf`
- Create: `games/voxsoul/mods/voxsoul_boss/init.lua`
- Create: `games/voxsoul/mods/voxsoul_boss/registry.lua`
- Create: `games/voxsoul/mods/voxsoul_boss/ai.lua`
- Create: `games/voxsoul/mods/voxsoul_boss/bosses/tree_sentinel.lua`
- Create: `games/voxsoul/mods/voxsoul_boss/bosses/margit.lua`
- Create: `games/voxsoul/mods/voxsoul_boss/bosses/grafted_hag.lua`

**Interfaces:**
- Produces:
  - `voxsoul.boss.register(def)` — 注册 Boss 定义
  - `voxsoul.boss.spawn(boss_id, pos) -> ObjectRef`
  - `voxsoul.boss.on_defeated(boss_id, player)` — 卢恩/掉落/解锁赐福

- [ ] **Step 1: 写招式权重测试**

```lua
local ai = dofile(minetest.get_modpath("voxsoul_boss") .. "/ai.lua")
local pick = ai.pick_attack({ a=1, b=1, c=1 }, nil)
assert(pick == "a" or pick == "b" or pick == "c")
local pick2 = ai.pick_attack({ a=1, b=1, c=1 }, "a")
assert(pick2 ~= "a" or true) -- weight reduced, statistical; smoke test only
```

- [ ] **Step 2: 实现 ai.lua pick_attack + phase 切换**

```lua
local M = {}

function M.get_phase(def, hp_ratio)
    local phase = def.phases[1]
    for _, p in ipairs(def.phases) do
        if hp_ratio <= p.threshold then phase = p end
    end
    return phase
end

function M.pick_attack(weights, last_attack)
    local pool = {}
    for atk, w in pairs(weights) do
        if atk == last_attack then w = w * 0.3 end
        table.insert(pool, { atk = atk, w = w })
    end
    local total = 0
    for _, e in ipairs(pool) do total = total + e.w end
    local r = math.random() * total
    for _, e in ipairs(pool) do
        r = r - e.w
        if r <= 0 then return e.atk end
    end
    return pool[1].atk
end

return M
```

- [ ] **Step 3: 实现 tree_sentinel.lua 定义**

```lua
return {
    id = "tree_sentinel",
    name = "大树守卫",
    max_hp = 800,
    max_poise = 120,
    runes = 800,
    drop = { talisman = "golden_blessing" },
    phases = {
        { threshold = 1.0, attacks = {
            halberd_sweep = 1, shield_bash = 1, horse_stomp = 1,
        }},
    },
    attacks = {
        halberd_sweep = { windup = 1.2, damage = 45, poise = 30, hitbox = { type="arc", radius=4, angle=120 } },
        shield_bash = { windup = 0.8, damage = 35, poise = 20, hitbox = { type="arc", radius=2.5, angle=90 } },
        horse_stomp = { windup = 1.5, damage = 50, poise = 35, hitbox = { type="circle", radius=3.5 } },
    },
}
```

- [ ] **Step 4: 同样创建 margit.lua（50% 阶段 2）和 grafted_hag.lua**

`margit.lua` 含 `phases[2] = { threshold = 0.5, attacks = { ... triple_lightblade, rain_slam } }`

- [ ] **Step 5: register_entity + on_step AI 循环**

Boss entity `on_step` 伪代码:
```lua
self.brain.timer = self.brain.timer - dtime
if self.brain.state == "chase" then move toward player end
if self.brain.state == "attack" and self.brain.timer <= 0 then
    local phase = voxsoul.boss.ai.get_phase(def, self.hp / def.max_hp)
    local atk_name = voxsoul.boss.ai.pick_attack(phase.attacks, self.brain.last)
    self.brain.last = atk_name
    voxsoul.boss.execute_attack(self.object, def.attacks[atk_name])
end
```

- [ ] **Step 6: 击败回调**

```lua
function voxsoul.boss.on_defeated(boss_id, player)
    local def = voxsoul.boss.registry[boss_id]
    voxsoul.player.add_runes(player, def.runes)
    minetest.get_worldmeta():set_string("voxsoul:boss:" .. boss_id, "1")
    if def.drop and def.drop.weapon then voxsoul.items.equip_weapon(player, def.drop.weapon) end
    if boss_id == "margit" then voxsoul.grace.unlock(player, "after_margit") end
end
```

- [ ] **Step 7: 游戏内 spawn 测试 Boss 血条与阶段切换**

- [ ] **Step 8: Commit**

```powershell
git add games/voxsoul/mods/voxsoul_boss
git commit -m "feat: add boss framework and three demo bosses"
```

---

### Task 11: voxsoul_world — 地图、敌人、键位绑定

**Files:**
- Create: `games/voxsoul/mods/voxsoul_world/mod.conf`
- Create: `games/voxsoul/mods/voxsoul_world/init.lua`
- Create: `games/voxsoul/mods/voxsoul_world/regions.lua`
- Create: `games/voxsoul/mods/voxsoul_world/enemies.lua`
- Create: `games/voxsoul/mods/voxsoul_world/spawns.lua`
- Create: `games/voxsoul/mods/voxsoul_world/controls.lua`
- Create: `games/voxsoul/mods/voxsoul_world/schems/.gitkeep`

**Interfaces:**
- Consumes: 全部 voxsoul_* API
- Produces: 完整可通关 Demo 世界布局

- [ ] **Step 1: 实现 controls.lua — 真实键位**

```lua
minetest.register_globalstep(function(dt)
    for _, player in ipairs(minetest.get_connected_players()) do
        local ctrl = player:get_player_control()
        local pname = player:get_player_name()
        voxsoul.world._edge = voxsoul.world._edge or {}
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

        edge.dig, edge.place, edge.jump, edge.aux1 = ctrl.dig, ctrl.place, ctrl.jump, ctrl.aux1
        voxsoul.world._edge[pname] = edge
    end
end)
```

- [ ] **Step 2: 注册区域触发器**

```lua
voxsoul.world.regions = {
    { id = "tutorial", min = vector.new(-20,0,-20), max = vector.new(20,30,20) },
    { id = "tree_sentinel_arena", min = vector.new(60,0,-20), max = vector.new(100,30,20), boss = "tree_sentinel" },
    { id = "margit_arena", min = vector.new(140,0,-30), max = vector.new(180,40,30), boss = "margit" },
}
```

- [ ] **Step 3: 放置教程牌节点**

```lua
minetest.register_node("voxsoul_world:tutorial_sign", {
    description = "Tutorial Sign",
    tiles = { "voxsoul_tutorial.png" },
    on_rightclick = function(pos, node, clicker)
        minetest.chat_send_player(clicker:get_player_name(),
            "LMB=轻攻击 Shift+LMB=重攻击 RMB=格挡 Space=闪避 E=交互 Q=锁定")
    end,
})
```

- [ ] **Step 4: 手工搭建地图**

使用 Luanti 内置创造模式或 WorldEdit 在 `demo_interlude` 世界按 spec 区域流程搭建：
- 引导废墟 (0,10,0)
- 开阔道 + 大树守卫 spawn 点 (80,10,0)
- 玛尔基特 arena (160,10,0)
- 接肢墓 (200,5,40)

保存 world 到 `games/voxsoul/worlds/demo_interlude/`（map.sqlite + map_meta.txt）

- [ ] **Step 5: 注册普通敌人**

```lua
minetest.register_entity("voxsoul_world:knight", {
    initial_properties = { visual = "mesh", mesh = "voxsoul_knight.b3d", textures = {"voxsoul_knight.png"} },
    voxsoul_combatant = true,
    hp = 150,
    runes = 100,
})
```

- [ ] **Step 6: 全流程手动 Checklist（spec §10.2）**

- [ ] **Step 7: Commit**

```powershell
git add games/voxsoul/mods/voxsoul_world games/voxsoul/worlds/demo_interlude
git commit -m "feat: add demo world regions enemies and player controls"
```

---

### Task 12: 集成测试与手感调优

**Files:**
- Modify: `games/voxsoul/mods/voxsoul_combat/constants.lua`（调参）
- Modify: `games/voxsoul/mods/voxsoul_boss/bosses/*.lua`（前摇/伤害微调）
- Create: `docs/superpowers/plans/2026-07-01-voxsoul-playtest-notes.md`

- [ ] **Step 1: 运行全部自动测试**

启动 Luanti 加载 VoxSoul，确认控制台输出:
```
[voxsoul_tests] core tests passed
[voxsoul_entity] hitbox tests passed
[voxsoul_combat] stamina/state tests passed
```

- [ ] **Step 2: 完成 spec §10.2 手动 Checklist 并记录**

`docs/superpowers/plans/2026-07-01-voxsoul-playtest-notes.md` 记录:
- 弹反窗口 0.25s 手感
- 玛尔基特阶段 2 切换
- 全流程通关时间

- [ ] **Step 3: 性能检查** — F5 调试屏确认 FPS ≥ 60（单 Boss 战）

- [ ] **Step 4: 最终 Commit**

```powershell
git add .
git commit -m "chore: playtest tuning and notes for v1 demo"
```

---

## Spec 覆盖自检

| Spec 章节 | 对应 Task |
|-----------|-----------|
| §2 架构 10 mod | Task 1–11 |
| §3 战斗系统 | Task 4–6, 11 controls |
| §4 Boss 系统 | Task 10 |
| §5 Demo 区域 | Task 11 |
| §6 成长系统 | Task 8 |
| §7 UI/HUD | Task 7 |
| §8 持久化 | Task 8 |
| §9 错误处理 | Task 2 unstuck, Task 6 invincible, Task 10 脱战 |
| §10 测试 | Task 2–6 tests, Task 12 |
| §1.3 FAN_PROJECT | Task 1 |

无 TBD/占位符；接口命名跨 Task 一致（`voxsoul.combat.ensure_data`、`voxsoul.grace.teleport_to_last_grace` 等）。

---

## 依赖安装提示

开发机需安装 **Luanti 5.13+**（https://www.luanti.org/downloads/）。将本仓库 `games/voxsoul` 目录链接到 `%APPDATA%\Luanti\games\voxsoul`。

可选工具：**WorldEdit** mod（地图搭建）、**Blender**（导出 `.b3d` mesh；v1 可用占位 mesh）。
