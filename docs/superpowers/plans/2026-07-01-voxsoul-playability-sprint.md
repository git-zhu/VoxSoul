# VoxSoul Playability Sprint A 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 统一 Demo 地图高度与坐标，修复 HP/锁定/伤害链路，使玩家能从出生步行击败 3 个 Boss 并完成赐福/死亡循环。

**Architecture:** 新增 `voxsoul_world/constants.lua` 作为 `FLOOR_Y`/`SPAWN` 唯一来源；`map_version=2` 触发全图重建；combat HP 为权威血条；Z 键（zoom）触发锁定并朝向目标。

**Tech Stack:** Luanti 5.16.1、Lua 5.1、现有 10 mod 架构

## Global Constraints

- Luanti **5.13+**（当前开发环境 5.16.1）
- **纯单人** Demo；本 Sprint 不做 mesh Boss
- **手工地图**（`map_builder.lua`），`FLOOR_Y = 20` 全图统一
- 锁定键：**Z**（`player:get_player_control().zoom`），保留 `/lockon`
- 粉丝项目，不扩大 scope 至视觉/手感调参
- 自动测试 `voxsoul_tests` 必须保持 PASS
- 运行验证：`play-voxsoul.bat` + 查看 `tools/luanti-client.log`

---

### Task A1: 世界常量与地图版本重建

**Files:**
- Create: `games/voxsoul/mods/voxsoul_world/constants.lua`
- Modify: `games/voxsoul/mods/voxsoul_world/init.lua`
- Modify: `games/voxsoul/mods/voxsoul_world/spawn.lua`
- Modify: `games/voxsoul/mods/voxsoul_world/map_builder.lua`

**Interfaces:**
- Produces: `voxsoul.world.FLOOR_Y` (number), `voxsoul.world.SPAWN` (vector), `voxsoul.world.MAP_VERSION` (string `"2"`)
- Consumes: `voxsoul.get_string` / `voxsoul.set_string` from `voxsoul_core`

- [ ] **Step 1: 创建 constants.lua**

```lua
voxsoul.world = voxsoul.world or {}

voxsoul.world.MAP_VERSION = "2"
voxsoul.world.FLOOR_Y = 20
voxsoul.world.SPAWN = vector.new(0, voxsoul.world.FLOOR_Y + 1, 0)
```

- [ ] **Step 2: init.lua 最先 dofile constants**

在 `dofile(nodes.lua)` 之前：

```lua
dofile(minetest.get_modpath("voxsoul_world") .. "/constants.lua")
```

删除 `local SPAWN_Y = 11`，改为：

```lua
local function spawn_y()
    return voxsoul.world.FLOOR_Y + 1
end
```

所有 `SPAWN_Y` 替换为 `spawn_y()`（敌兵、Boss join 刷新）。

- [ ] **Step 3: spawn.lua 引用常量**

删除文件顶部 `local FLOOR_Y = 20` 与 `local SPAWN = ...`，改用 `voxsoul.world.FLOOR_Y` / `voxsoul.world.SPAWN`；`get_spawn_pos()` 返回 `voxsoul.world.SPAWN`。

- [ ] **Step 4: map_builder.lua 使用 FLOOR_Y 常量**

文件顶部：`local FLOOR_Y = voxsoul.world.FLOOR_Y`（constants 已加载）。

替换 `ensure_map`：

```lua
function voxsoul.world.ensure_map()
    if voxsoul.get_string("voxsoul:map_version") == voxsoul.world.MAP_VERSION then
        return
    end
    voxsoul.world.build_map()
end
```

`build_map` 末尾：

```lua
voxsoul.set_string("voxsoul:map_version", voxsoul.world.MAP_VERSION)
minetest.log("action", "[voxsoul_world] Demo map v" .. voxsoul.world.MAP_VERSION .. " build complete")
```

删除 `voxsoul:map_built` 写入。

- [ ] **Step 5: 调整 build_ruins 与教程区**

`build_ruins` 在 `(0,0)` 建 31×31 砖地作为教程区（与 `ensure_spawn_pad` 范围对齐），教程牌 `(0, FLOOR_Y+1, 3)`，gatefront 赐福节点 `(0, FLOOR_Y, 8)`。

简化 `ensure_spawn_pad`：仅补灯光与空气层，不再重复铺整片地板（或合并进 `build_ruins` 后删除重复逻辑）。

- [ ] **Step 6: 验证地图重建**

Run:

```powershell
# 清除旧版本标记以强制重建（开发机）
# 编辑 worlds/demo_interlude/mod_storage/voxsoul_core 删除 map_version 或设为 1
python -c "print('manual: delete voxsoul:map_version from mod_storage or bump world')"
& "d:\Z\game\VoxSoul\tools\luanti\luanti-5.16.1-win64\bin\luanti.exe" --world "d:\Z\game\VoxSoul\games\voxsoul\worlds\demo_interlude" --gameid voxsoul --go --name Tarnished --logfile "d:\Z\game\VoxSoul\tools\luanti-client.log"
```

Expected log: `[voxsoul_world] Demo map v2 build complete`

- [ ] **Step 7: Commit**

```bash
git add games/voxsoul/mods/voxsoul_world/
git commit -m "feat(world): unify FLOOR_Y=20 and map version 2 rebuild"
```

---

### Task A2: 赐福与实体坐标对齐

**Files:**
- Modify: `games/voxsoul/mods/voxsoul_grace/init.lua`
- Modify: `games/voxsoul/mods/voxsoul_world/map_builder.lua`（赐福节点与 arena 内赐福）
- Modify: `games/voxsoul/mods/voxsoul_world/init.lua`（grafted_hag spawn y）

**Interfaces:**
- Consumes: `voxsoul.world.FLOOR_Y`

- [ ] **Step 1: 更新 grace.register 坐标**

```lua
local Y = 20  -- 或 voxsoul.world.FLOOR_Y if grace loads after world constants
voxsoul.grace.register("gatefront", { name = "Gatefront Grace", pos = vector.new(0, Y, 8), unlock = "default" })
voxsoul.grace.register("stormhill", { name = "Stormhill Grace", pos = vector.new(80, Y, -12), unlock = "proximity" })
voxsoul.grace.register("after_margit", { name = "After Margit Grace", pos = vector.new(170, Y, 5), unlock = "boss:margit" })
voxsoul.grace.register("catacombs", { name = "Catacombs Grace", pos = vector.new(200, Y, 35), unlock = "proximity" })
```

- [ ] **Step 2: map_builder 内 GRACE 节点 Y 已为 FLOOR_Y（随常量自动对齐）**

确认 `build_sentinel_arena` 赐福 `(80, FLOOR_Y, -12)`、`build_margit_arena` `(160, FLOOR_Y, -25)`、`build_catacombs` `(200, FLOOR_Y, 35)` 与 register 一致。

- [ ] **Step 3: 普通敌兵与鬼婆刷新**

`init.lua`：

```lua
register_spawn(vector.new(50, spawn_y(), 5), "voxsoul_world:knight")
register_spawn(vector.new(55, spawn_y(), -5), "voxsoul_world:knight")
-- catacombs enemies
register_spawn(vector.new(210, spawn_y(), 45), "voxsoul_world:omen_freak")
-- ...
voxsoul.boss.spawn("grafted_hag", vector.new(230, spawn_y(), 50))
```

- [ ] **Step 4: 游戏内 F5 核对**

从出生 `(0,21,0)` 向东走，地板连续至 x≈80。

- [ ] **Step 5: Commit**

```bash
git add games/voxsoul/mods/voxsoul_grace/init.lua games/voxsoul/mods/voxsoul_world/init.lua
git commit -m "fix: align grace and spawn coords to FLOOR_Y=20"
```

---

### Task A3: HP 统一与引擎伤害隔离

**Files:**
- Modify: `games/voxsoul/mods/voxsoul_combat/init.lua`
- Modify: `games/voxsoul/mods/voxsoul_player/init.lua`（如需要）
- Modify: `games/voxsoul/mods/voxsoul_tests/init.lua`

**Interfaces:**
- Produces: `voxsoul.combat.sync_engine_hp(player)` 可选 helper
- Consumes: `voxsoul.combat.ensure_data`

- [ ] **Step 1: 阻止引擎 HP 变化**

在 `voxsoul_combat/init.lua`：

```lua
minetest.register_on_player_hpchange(function(player, hp_change)
    return true  -- cancel engine damage/heal; combat owns HP
end)
```

- [ ] **Step 2: join 时初始化 combat HP**

```lua
minetest.register_on_joinplayer(function(player)
    voxsoul.combat.ensure_data(player)
    local data = voxsoul.combat.ensure_data(player)
    player:set_hp(math.max(1, math.min(20, math.ceil(20 * data.hp / data.max_hp))))
end)
```

- [ ] **Step 3: globalstep 同步 HUD 用 combat HP；死亡检测**

在现有 globalstep 末尾：

```lua
if data.hp <= 0 and data.state ~= "dead" then
    data.state = "dead"
    if voxsoul.player then voxsoul.player.on_death(player) end
elseif data.hp > 0 and data.state == "dead" then
    data.state = "idle"
end
```

`on_death` 内复活后 `data.state = "idle"`（已有）。

- [ ] **Step 4: grace.rest 后同步 engine hp**

`voxsoul_grace/rest` 已有 `cd.hp = cd.max_hp`；rest 后调用 `player:set_hp(20)`。

- [ ] **Step 5: 测试断言**

`voxsoul_tests/init.lua` 增加：

```lua
assert(voxsoul.world.FLOOR_Y == 20, "FLOOR_Y must be 20")
```

Run headless join — all tests passed.

- [ ] **Step 6: Commit**

```bash
git add games/voxsoul/mods/voxsoul_combat/init.lua games/voxsoul/mods/voxsoul_tests/init.lua
git commit -m "fix(combat): unify HP authority and block engine damage"
```

---

### Task A4: Z 键锁定与朝向

**Files:**
- Modify: `games/voxsoul/mods/voxsoul_world/init.lua`
- Modify: `games/voxsoul/mods/voxsoul_combat/lockon.lua`
- Modify: `README.md`

**Interfaces:**
- Consumes: `voxsoul.combat.toggle_lockon`, `voxsoul.combat.get_lock_target`

- [ ] **Step 1: world globalstep 检测 Z（zoom）边沿**

在 `voxsoul.world._edge` 增加 `zoom` 字段：

```lua
if ctrl.zoom and not edge.zoom then
    voxsoul.combat.toggle_lockon(player)
end
edge.zoom = ctrl.zoom
```

- [ ] **Step 2: lockon 朝向目标**

新建或在 `lockon.lua` 增加：

```lua
function voxsoul.combat.update_lockon_facing(player)
    local target = voxsoul.combat.get_lock_target(player)
    if not target then return end
    local pos = player:get_pos()
    local tpos = target:get_pos()
    local yaw = minetest.dir_to_yaw(vector.direction(pos, tpos))
    player:set_look_horizontal(yaw)
end
```

在 `voxsoul_combat` globalstep 或 `voxsoul_world` globalstep 每帧调用 `update_lockon_facing`。

- [ ] **Step 3: 更新 README 操作表**

| Z | 锁定/取消锁定最近敌人 |
| `/lockon` | 同上（后备） |

- [ ] **Step 4: Commit**

```bash
git add games/voxsoul/mods/voxsoul_world/init.lua games/voxsoul/mods/voxsoul_combat/lockon.lua README.md
git commit -m "feat(combat): bind lock-on to Z key with facing"
```

---

### Task A5: 伤害链路验证与 Boss 修复

**Files:**
- Modify: `games/voxsoul/mods/voxsoul_boss/init.lua`
- Modify: `games/voxsoul/mods/voxsoul_combat/attacks.lua`
- Modify: `games/voxsoul/mods/voxsoul_world/init.lua`（enemy on_hit）

**Interfaces:**
- Consumes: `voxsoul.combat.apply_damage_to_entity`, `apply_damage_to_player`

- [ ] **Step 1: 修复 Boss hit 时机**

当前 `on_step` attack 状态中 `hit_applied` 逻辑可能永不触发伤害。改为 windup 结束时命中：

```lua
if self.brain.state == "attack" then
    self.brain.timer = self.brain.timer - dtime
    if not self.brain.hit_applied and self.brain.timer <= self.brain.windup_remaining then
        voxsoul.combat.hit_entity_with_attack(self.object, self.brain.current_atk, target)
        self.brain.hit_applied = true
    end
    if self.brain.timer <= 0 then
        self.brain.state = "recovery"
        self.brain.timer = 0.5
    end
    return
end
```

- [ ] **Step 2: 确认玩家攻击 Boss**

`resolve_attack_hit` 已检测 `ent.voxsoul_combatant`；Boss entity 有该 flag。游戏内 LMB 攻击 Boss，观察 Boss 血条下降。

- [ ] **Step 3: 普通敌人 punch 回调**

确认 `voxsoul_world:knight` 的 `on_hit` 在 hp<=0 时 remove；玩家攻击通过 combat 系统而非 engine punch。

- [ ] **Step 4: Commit**

```bash
git add games/voxsoul/mods/voxsoul_boss/init.lua
git commit -m "fix(boss): apply attack damage at windup end"
```

---

### Task A6: HUD 警告与 Playtest 文档

**Files:**
- Modify: `games/voxsoul/mods/voxsoul_ui/hud.lua`
- Modify: `docs/superpowers/plans/2026-07-01-voxsoul-playtest-notes.md`

- [ ] **Step 1: hud_elem_type → type**

```lua
type = "text",  -- 替换 hud_elem_type
```

两处（玩家 HUD + Boss 血条）。

- [ ] **Step 2: 手动 playtest 并更新 checklist**

按 spec §5.2 逐项测试，在 `playtest-notes.md` 勾选并记录问题。

- [ ] **Step 3: Commit**

```bash
git add games/voxsoul/mods/voxsoul_ui/hud.lua docs/superpowers/plans/2026-07-01-voxsoul-playtest-notes.md
git commit -m "docs: playtest sprint A results and fix HUD type field"
```

---

## Plan Self-Review

| Spec 要求 | 对应 Task |
|-----------|-----------|
| FLOOR_Y=20 统一 | A1 |
| map_version 重建 | A1 |
| 路线连通 | A1, A2 |
| HP 统一 | A3 |
| Z 锁定 | A4 |
| 伤害链路 | A5 |
| HUD 警告 | A6 |
| Playtest ≥80% | A6 |
| 不做 mesh/telegraph | 全局约束 |

无 TBD/placeholder。类型名 `FLOOR_Y`、`MAP_VERSION`、`toggle_lockon` 全文一致。

---

## 开发机地图重建提示

若进游戏仍是 y=10 旧地图，删除或编辑：

`games/voxsoul/worlds/demo_interlude/mod_storage/voxsoul_core`

移除 `voxsoul:map_built` / 旧 `map_version`，或新建世界。
