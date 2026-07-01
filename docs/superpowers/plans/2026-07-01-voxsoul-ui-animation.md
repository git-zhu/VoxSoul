# VoxSoul UI & Animation Sprint B 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 用 Luanti statbar 替换 ASCII HUD，补 Boss 条与锁定标记；在现有 b3d 上建立语义战斗动画映射，使攻击/闪避可区分。

**Architecture:** `voxsoul_ui` 拆为 `hud.lua`（常驻条）、`boss_hud.lua`（Boss 顶栏）、`lockon_marker.lua`（world_pos 红圈）；`player_model.lua` 只读 combat state 按优先级选动画；`attacks.lua` 写入 `attack_kind`。

**Tech Stack:** Luanti 5.16.1、Lua 5.1、PIL（`tools/gen_ui_textures.py`）、现有 10 mod 架构

## Global Constraints

- Luanti **5.13+**（当前开发环境 **5.16.1**）
- **纯单人** Demo；本 Sprint 不引入新 b3d 模型
- 动画资源 **A**：现有 `voxsoul_tarnished.b3d` 帧重映射
- 锁定键：**Z**（`player:get_player_control().zoom`）
- `disable_defaults.lua` 保持 `healthbar = false`
- 自动测试 `voxsoul_tests` 必须保持 PASS
- 运行验证：`play-voxsoul.bat` + 查看 `tools/luanti-client.log`
- manual checklist ≥ **80%** 勾选（见 spec §5.2）

---

### Task B1: UI 纹理资源

**Files:**
- Create: `tools/gen_ui_textures.py`
- Create: `games/voxsoul/mods/voxsoul_ui/textures/voxsoul_hp.png`
- Create: `games/voxsoul/mods/voxsoul_ui/textures/voxsoul_hp_bg.png`
- Create: `games/voxsoul/mods/voxsoul_ui/textures/voxsoul_stamina.png`
- Create: `games/voxsoul/mods/voxsoul_ui/textures/voxsoul_stamina_bg.png`
- Create: `games/voxsoul/mods/voxsoul_ui/textures/voxsoul_lockon.png`

**Interfaces:**
- Produces: mod-local texture names `voxsoul_hp.png`, `voxsoul_hp_bg.png`, `voxsoul_stamina.png`, `voxsoul_stamina_bg.png`, `voxsoul_lockon.png`

- [ ] **Step 1: 创建 gen_ui_textures.py**

```python
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1] / "games" / "voxsoul" / "mods" / "voxsoul_ui" / "textures"
ROOT.mkdir(parents=True, exist_ok=True)

def half_bar(path: Path, fill: tuple[int, int, int], bg: tuple[int, int, int]) -> None:
    img = Image.new("RGBA", (16, 16), bg + (255,))
    draw = ImageDraw.Draw(img)
    draw.rectangle((0, 4, 15, 11), fill=fill + (255,))
    img.save(path)

half_bar(ROOT / "voxsoul_hp.png", (200, 40, 40), (60, 20, 20))
half_bar(ROOT / "voxsoul_hp_bg.png", (80, 30, 30), (40, 15, 15))
half_bar(ROOT / "voxsoul_stamina.png", (40, 180, 60), (20, 60, 30))
half_bar(ROOT / "voxsoul_stamina_bg.png", (30, 80, 40), (15, 40, 20))

lock = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
draw = ImageDraw.Draw(lock)
draw.ellipse((2, 2, 13, 13), outline=(220, 40, 40, 255), width=2)
lock.save(ROOT / "voxsoul_lockon.png")
print("UI textures written to", ROOT)
```

- [ ] **Step 2: 运行生成脚本**

Run:

```powershell
python "d:\Z\game\VoxSoul\tools\gen_ui_textures.py"
```

Expected: `UI textures written to ...\voxsoul_ui\textures`

- [ ] **Step 3: Commit**

```bash
git add tools/gen_ui_textures.py games/voxsoul/mods/voxsoul_ui/textures/
git commit -m "feat(ui): add statbar and lockon HUD textures"
```

---

### Task B2: 常驻 HUD（HP / 耐力 / 卢恩）

**Files:**
- Modify: `games/voxsoul/mods/voxsoul_ui/hud.lua`（重写）
- Modify: `games/voxsoul/mods/voxsoul_ui/init.lua`

**Interfaces:**
- Consumes: `voxsoul.combat.ensure_data(player)` → `{ hp, max_hp, stamina, max_stamina }`
- Consumes: `voxsoul.player.get_runes(player)` → number
- Produces: `voxsoul.ui.update_player_hud(player)` — 每 globalstep 调用

- [ ] **Step 1: 重写 hud.lua**

```lua
local hud_ids = {}
local STAMINA_BAR_MAX = 20
local HP_BAR_MAX = 20
local blink_timer = 0
local blink_visible = true

local function statbar_count(current, maximum, bar_max)
    if maximum <= 0 then
        return 0, bar_max
    end
    return math.ceil(bar_max * current / maximum), bar_max
end

function voxsoul.ui.update_player_hud(player)
    local name = player:get_player_name()
    local d = voxsoul.combat.ensure_data(player)
    hud_ids[name] = hud_ids[name] or {}
    local ids = hud_ids[name]

    local hp_num, hp_bg = statbar_count(d.hp, d.max_hp, HP_BAR_MAX)
    local st_num, st_bg = statbar_count(d.stamina, d.max_stamina, STAMINA_BAR_MAX)

    if voxsoul.combat.stamina.is_exhausted(d.stamina, d.max_stamina) then
        blink_timer = blink_timer + 0.05
        if blink_timer >= 0.5 then
            blink_timer = 0
            blink_visible = not blink_visible
        end
        if not blink_visible then
            st_num = 0
        end
    else
        blink_visible = true
        blink_timer = 0
    end

    local runes = voxsoul.player and voxsoul.player.get_runes(player) or 0

    if not ids.hp then
        ids.hp = player:hud_add({
            type = "statbar",
            position = { x = 0.02, y = 0.90 },
            offset = { x = 4, y = 0 },
            size = { x = 16, y = 16 },
            text = "voxsoul_hp.png",
            text2 = "voxsoul_hp_bg.png",
            number = hp_num,
            item = hp_bg,
            direction = 0,
            z_index = 100,
        })
        ids.stamina = player:hud_add({
            type = "statbar",
            position = { x = 0.02, y = 0.94 },
            offset = { x = 4, y = 0 },
            size = { x = 16, y = 16 },
            text = "voxsoul_stamina.png",
            text2 = "voxsoul_stamina_bg.png",
            number = st_num,
            item = st_bg,
            direction = 0,
            z_index = 100,
        })
        ids.runes = player:hud_add({
            type = "text",
            position = { x = 0.75, y = 0.90 },
            offset = { x = 0, y = 0 },
            scale = { x = 120, y = 120 },
            text = "Runes: " .. runes,
            number = 0xFFD700,
            z_index = 100,
        })
    else
        player:hud_change(ids.hp, "number", hp_num)
        player:hud_change(ids.stamina, "number", st_num)
        player:hud_change(ids.runes, "text", "Runes: " .. runes)
    end
end

function voxsoul.ui.clear_player_hud(player)
    local name = player:get_player_name()
    local ids = hud_ids[name]
    if not ids then
        return
    end
    for _, id in pairs(ids) do
        player:hud_remove(id)
    end
    hud_ids[name] = nil
end

function voxsoul.ui.show_death(player, lost, grace_name)
    minetest.show_formspec(player:get_player_name(), "voxsoul:death",
        "size[8,4]label[0,0;YOU DIED]label[0,1;Lost runes: " .. lost .. "]label[0,2;Revive at: " .. grace_name .. "]")
end
```

- [ ] **Step 2: init.lua 注册 leave 清理**

在 `init.lua` 末尾添加：

```lua
minetest.register_on_leaveplayer(function(player)
    voxsoul.ui.clear_player_hud(player)
end)
```

- [ ] **Step 3: 验证 mod 加载**

Run:

```powershell
Set-Location "d:\Z\game\VoxSoul\tools\luanti\luanti-5.16.1-win64"
Start-Process ".\bin\luanti.exe" -ArgumentList @("--server","--world","d:\Z\game\VoxSoul\games\voxsoul\worlds\demo_interlude","--gameid","voxsoul","--logfile","d:\Z\game\VoxSoul\tools\luanti-server-test.log")
Start-Sleep 8
Select-String -Path "d:\Z\game\VoxSoul\tools\luanti-server-test.log" -Pattern "ModError|ERROR|passed"
```

Expected: all `[voxsoul_tests] ... passed`, no ModError

- [ ] **Step 4: Commit**

```bash
git add games/voxsoul/mods/voxsoul_ui/hud.lua games/voxsoul/mods/voxsoul_ui/init.lua
git commit -m "feat(ui): replace ASCII HUD with statbar HP and stamina"
```

---

### Task B3: Boss 血条

**Files:**
- Create: `games/voxsoul/mods/voxsoul_ui/boss_hud.lua`
- Modify: `games/voxsoul/mods/voxsoul_ui/hud.lua`（删除旧 `show_boss_bar` / `hide_boss_bar`）
- Modify: `games/voxsoul/mods/voxsoul_ui/init.lua`
- Modify: `games/voxsoul/mods/voxsoul_boss/init.lua`（无需改，仍调用 `voxsoul.ui.show_boss_bar`）

**Interfaces:**
- Produces: `voxsoul.ui.show_boss_bar(boss_id, boss_name, hp, max_hp)`
- Produces: `voxsoul.ui.hide_boss_bar(boss_id)`

- [ ] **Step 1: 创建 boss_hud.lua**

```lua
local boss_huds = {}
local BOSS_BAR_MAX = 20

local function bar_counts(hp, max_hp)
    if max_hp <= 0 then
        return 0, BOSS_BAR_MAX
    end
    return math.ceil(BOSS_BAR_MAX * hp / max_hp), BOSS_BAR_MAX
end

function voxsoul.ui.show_boss_bar(boss_id, boss_name, hp, max_hp)
    local num, bg = bar_counts(hp, max_hp)
    for _, player in ipairs(minetest.get_connected_players()) do
        local pname = player:get_player_name()
        boss_huds[pname] = boss_huds[pname] or {}
        local ids = boss_huds[pname][boss_id]
        if ids then
            player:hud_change(ids.name, "text", boss_name)
            player:hud_change(ids.bar, "number", num)
        else
            boss_huds[pname][boss_id] = {
                name = player:hud_add({
                    type = "text",
                    name = "voxsoul_boss_name_" .. boss_id,
                    position = { x = 0.5, y = 0.04 },
                    offset = { x = 0, y = 0 },
                    alignment = { x = 0, y = 0 },
                    scale = { x = 150, y = 150 },
                    text = boss_name,
                    number = 0xFF4444,
                    z_index = 200,
                }),
                bar = player:hud_add({
                    type = "statbar",
                    name = "voxsoul_boss_bar_" .. boss_id,
                    position = { x = 0.5, y = 0.08 },
                    offset = { x = -160, y = 0 },
                    size = { x = 16, y = 16 },
                    text = "voxsoul_hp.png",
                    text2 = "voxsoul_hp_bg.png",
                    number = num,
                    item = bg,
                    direction = 0,
                    z_index = 200,
                }),
            }
        end
    end
end

function voxsoul.ui.hide_boss_bar(boss_id)
    for _, player in ipairs(minetest.get_connected_players()) do
        local pname = player:get_player_name()
        local entry = boss_huds[pname] and boss_huds[pname][boss_id]
        if entry then
            player:hud_remove(entry.name)
            player:hud_remove(entry.bar)
            boss_huds[pname][boss_id] = nil
        end
    end
end

minetest.register_on_leaveplayer(function(player)
    boss_huds[player:get_player_name()] = nil
end)
```

- [ ] **Step 2: init.lua 加载 boss_hud**

```lua
voxsoul.ui = {}
dofile(minetest.get_modpath("voxsoul_ui") .. "/hud.lua")
dofile(minetest.get_modpath("voxsoul_ui") .. "/boss_hud.lua")
dofile(minetest.get_modpath("voxsoul_ui") .. "/lockon_marker.lua")
```

（`lockon_marker.lua` 在 Task B4 创建；若分步实施，B3 时先不加 lockon 行，B4 再补。）

- [ ] **Step 3: 从 hud.lua 删除旧 boss 函数**

删除 `hud.lua` 中 `local boss_huds` 及 `show_boss_bar` / `hide_boss_bar` 整段。

- [ ] **Step 4: Commit**

```bash
git add games/voxsoul/mods/voxsoul_ui/
git commit -m "feat(ui): add boss name and statbar HUD"
```

---

### Task B4: 锁定标记

**Files:**
- Create: `games/voxsoul/mods/voxsoul_ui/lockon_marker.lua`
- Modify: `games/voxsoul/mods/voxsoul_ui/init.lua`（globalstep 调用 marker 更新）

**Interfaces:**
- Consumes: `voxsoul.combat.get_lock_target(player)` → ObjectRef or nil
- Produces: `voxsoul.ui.update_lockon_marker(player)` — 每 globalstep 调用

- [ ] **Step 1: 创建 lockon_marker.lua**

```lua
local markers = {}

local function hide_marker(player, name)
    local ids = markers[name]
    if not ids then
        return
    end
    if ids.image then
        player:hud_remove(ids.image)
    end
    if ids.fallback then
        player:hud_remove(ids.fallback)
    end
    markers[name] = nil
end

function voxsoul.ui.update_lockon_marker(player)
    local name = player:get_player_name()
    local target = voxsoul.combat.get_lock_target(player)
    if not target or not target:get_pos() then
        hide_marker(player, name)
        return
    end

    local tpos = target:get_pos()
    local world_pos = { x = tpos.x, y = tpos.y + 0.05, z = tpos.z }
    local ids = markers[name]

    if not ids then
        local image_id = player:hud_add({
            type = "image_waypoint",
            name = "voxsoul_lockon",
            scale = { x = 1.5, y = 1.5 },
            text = "voxsoul_lockon.png",
            world_pos = world_pos,
            offset = { x = 0, y = -16 },
            alignment = { x = 0, y = 0 },
            z_index = 50,
        })
        markers[name] = { image = image_id }
    else
        player:hud_change(ids.image, "world_pos", world_pos)
    end
end

minetest.register_on_leaveplayer(function(player)
    hide_marker(player, player:get_player_name())
end)
```

若客户端 `image_waypoint` 不显示，在 Step 2 添加 fallback：同时显示屏幕角 `text` HUD `"LOCKED"`（spec §6 风险缓解）。

- [ ] **Step 2: init.lua 合并 globalstep**

```lua
minetest.register_globalstep(function()
    for _, player in ipairs(minetest.get_connected_players()) do
        voxsoul.ui.update_player_hud(player)
        voxsoul.ui.update_lockon_marker(player)
    end
end)
```

- [ ] **Step 3: Commit**

```bash
git add games/voxsoul/mods/voxsoul_ui/lockon_marker.lua games/voxsoul/mods/voxsoul_ui/init.lua
git commit -m "feat(ui): add lock-on ground marker HUD"
```

---

### Task B5: combat attack_kind 接口

**Files:**
- Modify: `games/voxsoul/mods/voxsoul_combat/attacks.lua`

**Interfaces:**
- Produces: `voxsoul.combat.ensure_data(player).attack_kind` — `"light"` | `"heavy"` | nil

- [ ] **Step 1: perform_attack 写入 attack_kind**

在 `data.state = "attacking"` 之后添加：

```lua
    data.attack_kind = kind == "heavy" and "heavy" or "light"
```

- [ ] **Step 2: 攻击结束清除 attack_kind**

在 `games/voxsoul/mods/voxsoul_combat/init.lua` 的 attacking 分支，当 `data.state` 回到 `"idle"` 时：

```lua
                data.attack_kind = nil
```

具体位置：`elseif data.state == "attacking"` 块内，`data.state = "idle"` 赋值处。

- [ ] **Step 3: 验证 tests**

Run headless server（同 Task B2 Step 3）。

Expected: `[voxsoul_combat] stamina/state tests passed`

- [ ] **Step 4: Commit**

```bash
git add games/voxsoul/mods/voxsoul_combat/attacks.lua games/voxsoul/mods/voxsoul_combat/init.lua
git commit -m "feat(combat): expose attack_kind for player animations"
```

---

### Task B6: 语义战斗动画

**Files:**
- Modify: `games/voxsoul/mods/voxsoul_player/player_model.lua`

**Interfaces:**
- Consumes: `voxsoul.combat.ensure_data(player)` → `{ state, blocking, attack_kind, hp }`
- Produces: 无新导出；`M.globalstep()` 内部按优先级调用 `M.set_animation`

- [ ] **Step 1: 扩展 register_model 动画表**

在 `M.register_model("voxsoul_tarnished.b3d", { ... })` 的 `animations` 中添加：

```lua
        attack_light = { x = 189, y = 198, override_local = true },
        attack_heavy = { x = 200, y = 219, override_local = true },
        dodge = { x = 168, y = 187, override_local = true },
        block = { x = 0, y = 79 },
        hitstun = { x = 0, y = 79, override_local = true },
        guardbreak = { x = 81, y = 160, override_local = true },
```

- [ ] **Step 2: 替换 combat_animation 函数**

```lua
local COMBAT_ANIM = {
    lay = { name = "lay", speed = 30, loop = false },
    hitstun = { name = "hitstun", speed = 10, loop = false },
    guardbreak = { name = "guardbreak", speed = 20, loop = false },
    attack_light = { name = "attack_light", speed = 40, loop = false },
    attack_heavy = { name = "attack_heavy", speed = 30, loop = false },
    dodge = { name = "dodge", speed = 60, loop = false },
    block = { name = "block", speed = 15, loop = true },
}

local function combat_animation(player)
    if not voxsoul.combat then
        return nil
    end
    local data = voxsoul.combat.ensure_data(player)
    if data.hp <= 0 or data.state == "dead" then
        return COMBAT_ANIM.lay
    end
    if data.state == "hitstun" then
        return COMBAT_ANIM.hitstun
    end
    if data.state == "guardbreak" then
        return COMBAT_ANIM.guardbreak
    end
    if data.state == "attacking" then
        if data.attack_kind == "heavy" then
            return COMBAT_ANIM.attack_heavy
        end
        return COMBAT_ANIM.attack_light
    end
    if data.state == "dodging" then
        return COMBAT_ANIM.dodge
    end
    if data.blocking or data.state == "blocking" then
        return COMBAT_ANIM.block
    end
    return nil
end
```

- [ ] **Step 3: globalstep 使用 combat_animation 返回值**

将 `combat_animation(player)` 改为返回表 `{ name, speed, loop }`：

```lua
            local forced = combat_animation(player)
            if forced then
                M.set_animation(player, forced.name, forced.speed, forced.loop)
            else
                -- 现有 locomotion 分支不变
```

- [ ] **Step 4: 手动验证动画**

Run `play-voxsoul.bat`，测试 LMB / Shift+LMB / Space+方向 / RMB。

Expected: 轻攻击 mine 段、重攻击 walk_mine 段、闪避快速 walk、格挡慢 stand

- [ ] **Step 5: Commit**

```bash
git add games/voxsoul/mods/voxsoul_player/player_model.lua
git commit -m "feat(player): semantic combat animations from existing b3d frames"
```

---

### Task B7: 测试、文档与收尾

**Files:**
- Modify: `docs/superpowers/plans/2026-07-01-voxsoul-playtest-notes.md`
- Modify: `README.md`
- Modify: `docs/superpowers/specs/2026-07-01-voxsoul-ui-animation-design.md`（状态 → Approved）

**Interfaces:**
- 无新 API

- [ ] **Step 1: 更新 playtest-notes Sprint B checklist**

在 `playtest-notes.md` 追加 Sprint B 手动项（spec §5.2 共 10 条），勾选代码已验证项。

- [ ] **Step 2: README 补充 HUD 说明**

在「操作」节后添加：

```markdown
## HUD

- 左下：红色 HP 条、绿色耐力条（耗尽时闪烁）
- 右下：卢恩数
- Boss 战：顶部 Boss 名 + 血条
- Z 锁定：目标脚下红色标记
```

- [ ] **Step 3: 全量自动测试**

Run headless + grep passed（同 B2 Step 3）。

- [ ] **Step 4: Push**

```bash
git add docs/ README.md
git commit -m "docs: Sprint B UI and animation playtest notes"
git push
```

---

## Spec Coverage Check

| Spec § | Task |
|--------|------|
| §2.1 常驻 statbar | B1, B2 |
| §2.2 卢恩 text | B2 |
| §2.3 Boss statbar | B3 |
| §2.4 锁定标记 | B4 |
| §2.5 保留 death/grace | B2（保留 show_death） |
| §2.6 移除 ASCII | B2, B3 |
| §3.1 语义动画表 | B6 |
| §3.2 优先级 | B6 |
| §3.3 attack_kind | B5 |
| §5.2 manual checklist | B7 |
| §6 image_waypoint fallback | B4 备注 |

## Execution Order

```
B1 → B2 → B3 → B4 → B5 → B6 → B7
```

B5 可与 B2–B4 并行；B6 依赖 B5。
