# VoxSoul — UI & 动作 Sprint B 设计规格

**日期**：2026-07-01  
**状态**：Draft — 待用户审阅  
**前置**：Playability Sprint A 已完成（map v2、战斗 HP、Z 锁定）  
**策略**：C — UI 与动作并行；动画资源 A — 现有 b3d 帧重映射

---

## 1. 目标

玩家进入游戏后 **5 秒内** 能清晰看到：

- 左下 HP / 耐力条
- 右下卢恩数
- Boss 战时顶部 Boss 血条
- 锁定时目标脚下红色标记

战斗时 **攻击与闪避动作可区分**（基于现有 `voxsoul_tarnished.b3d`，不引入新模型）。

### 1.1 非目标（本 Sprint）

- 法环风格高保真 UI 贴图（Phase 2）
- 新 b3d 战斗专用动画（Phase 2）
- Boss/敌人 mesh 动画
- 格挡/弹反独立姿态（占位即可）

---

## 2. UI 设计（`voxsoul_ui`）

### 2.1 常驻 HUD — 左下

| 元素 | 类型 | 位置 | 说明 |
|------|------|------|------|
| HP 条 | `statbar` | `{x=0.02, y=0.92}` | 红色半格纹理；`number = ceil(20 * hp/max_hp)` |
| 耐力条 | `statbar` | `{x=0.02, y=0.96}` | 绿色半格纹理；同上比例 |
| 耐力耗尽闪烁 | `hud_change` | — | 耐力 ≤ 0 时每 0.5s 切换 `number` 显示/隐藏 |

纹理：优先复用 Luanti 内置 `heart.png` / `bubble.png`；若子游戏内无内置路径，则在 `voxsoul_ui/textures/` 放置 `voxsoul_hp.png`、`voxsoul_stamina.png`（16×16 半格条）。

`text2` 字段用于 statbar 背景（满槽位灰色底）。

### 2.2 卢恩 — 右下

| 元素 | 类型 | 位置 | 说明 |
|------|------|------|------|
| 卢恩计数 | `text` | `{x=0.75, y=0.92}` | `Runes: N`，颜色 `0xFFD700` |

### 2.3 Boss 血条 — 顶部居中

| 元素 | 类型 | 位置 | 说明 |
|------|------|------|------|
| Boss 名 | `text` | `{x=0.5, y=0.04}` | 居中，`alignment = {x=0, y=0}` |
| Boss HP 条 | `statbar` | `{x=0.5, y=0.08}` | 红色，宽度 20 半格 |

替换现有 ASCII `bar()` 文本 Boss 条。阶段后缀（如「— Omen Form」）沿用 `voxsoul_boss` 现有逻辑。

### 2.4 锁定标记

锁定时在目标实体脚下显示红色圆环：

- 使用 `image` HUD + `world_pos`（Luanti 5.16 `image_waypoint` 或每帧 `hud_change` 更新 `world_pos`）
- 纹理：`voxsoul_ui/textures/voxsoul_lockon.png`（16×16 红色环，可程序生成）
- 位置：目标 `get_pos()` 的 Y 取地面 + 0.1
- 无锁定 / 目标失效：移除或隐藏 HUD

实现放在 `voxsoul_ui/lockon_marker.lua`，由 `voxsoul.combat.get_lock_target` 驱动。

### 2.5 保留不变

- 死亡 formspec（`show_death`）
- 赐福 formspec（`voxsoul_grace`）
- `disable_defaults.lua` 中 `healthbar = false`（使用自定义条）

### 2.6 移除

- `hud.lua` 中 ASCII `bar()` 主 HUD 文本条

---

## 3. 动作设计（`voxsoul_player/player_model.lua`）

### 3.1 语义动画映射

基于 `voxsoul_tarnished.b3d` 现有帧：

| 语义名 | b3d 帧 | 速度 | 循环 | 触发 |
|--------|--------|------|------|------|
| `stand` | 0–79 | 30 | ✓ | idle |
| `walk` | 168–187 | 30 | ✓ | 移动 |
| `attack_light` | 189–198 | 40 | ✗ | attacking + light |
| `attack_heavy` | 200–219 | 30 | ✗ | attacking + heavy |
| `dodge` | 168–187 | 60 | ✗ | dodging |
| `block` | 0–79 | 15 | ✓ | blocking |
| `hitstun` | 0–79 | 10 | ✗ | hitstun |
| `guardbreak` | 81–160 | 20 | ✗ | guardbreak |
| `lay` | 162–166 | 30 | ✗ | hp ≤ 0 |

### 3.2 优先级（高 → 低）

```
lay > hitstun / guardbreak > attack > dodge > block > locomotion
```

高优先级播放期间低优先级不抢占。非循环动画播放完毕后 globalstep 回落 locomotion。

### 3.3 combat 接口

- `voxsoul.combat.perform_attack(player, kind)` 写入 `data.attack_kind`（`"light"` / `"heavy"`）
- `player_model.globalstep` 只读 combat state，不修改战斗逻辑
- 伤害判定仍由 combat timer 负责，动画不驱动 hitbox

### 3.4 Phase 2 预留

- 新 b3d + Mixamo 战斗帧
- 格挡/弹反独立姿态
- `voxsoul_entity` 独立 FSM

---

## 4. 文件变更

| 文件 | 变更 |
|------|------|
| `voxsoul_ui/hud.lua` | 重写：statbar HP/耐力、text 卢恩 |
| `voxsoul_ui/boss_hud.lua` | 新建：Boss statbar + 名称 |
| `voxsoul_ui/lockon_marker.lua` | 新建：锁定圈 world_pos HUD |
| `voxsoul_ui/textures/` | 可选自定义 statbar 半格 + lockon 环 |
| `voxsoul_ui/init.lua` | 引入子模块；锁定 marker globalstep |
| `voxsoul_player/player_model.lua` | 语义映射表 + 优先级仲裁 |
| `voxsoul_combat/init.lua` 或 `attacks.lua` | 写入 `attack_kind` |
| `tools/gen_ui_textures.py` | 可选：生成 statbar / lockon PNG |
| `README.md` | HUD 说明 |

---

## 5. 测试

### 5.1 自动

- 现有 `voxsoul_tests` 保持 PASS
- 可选：`voxsoul_tests` 断言 join 后玩家 HUD id 非 nil

### 5.2 手动 checklist

- [ ] 进游戏左下可见红/绿条，随受伤/消耗变化
- [ ] 耐力耗尽时绿条闪烁
- [ ] 右下卢恩数正确
- [ ] 靠近 Boss 时顶部出现名称 + 血条，受伤后缩短
- [ ] Z 锁定敌人时脚下出现红圈，解锁或超出距离消失
- [ ] LMB 轻攻击：mine 段动画，约 0.5s 回 idle
- [ ] Shift+LMB 重攻击：walk_mine 段，与轻攻击不同
- [ ] Space+方向闪避：快速 walk 段，0.6s 内不被覆盖
- [ ] RMB 格挡：慢速 stand
- [ ] 死亡：lay 动画

**通过标准**：manual checklist ≥ 80% 勾选。

---

## 6. 风险

| 风险 | 缓解 |
|------|------|
| statbar 纹理路径因 Luanti 版本不同 | 子游戏内自带 `voxsoul_ui/textures/` 备份 |
| 非循环动画与 combat recovery 不同步 | 以 combat state 为准，动画跟随 state |
| image_waypoint 客户端不支持 | fallback：`text` HUD 显示「LOCKED」 |
| 第三人称下 HUD 遮挡 | 位置微调，Sprint 内不重构相机 |

---

## 7. 参考

- `docs/superpowers/specs/2026-07-01-voxsoul-elden-design.md` §7 UI/HUD
- `games/voxsoul/mods/voxsoul_ui/hud.lua`（当前 ASCII 实现）
- `games/voxsoul/mods/voxsoul_player/player_model.lua`（当前动画映射）
- Luanti 5.16 `statbar` HUD 定义（`doc/lua_api.md`）
