# VoxSoul — Playability Sprint A 设计规格

**日期**：2026-07-01  
**状态**：Approved  
**前置文档**：`2026-07-01-voxsoul-elden-design.md`  
**方案选择**：方案 1 — 统一地图高度 + 最小改动

---

## 1. 目标与成功标准

### 1.1 Sprint 目标

让玩家能从出生点**不卡关、不迷路**走到 3 个 Boss 并击败；赐福休息/升级/传送可用；死亡与卢恩循环可用。

### 1.2 成功标准（Task 12 子集）

1. 从出生 `(0, 21, 0)` 沿金纹路可步行至大树守卫 → 玛尔基特 → 接肢鬼婆，全程无不可跨越断档
2. 教程牌可读；LMB / Shift+LMB / RMB / Space+方向 / E 有明确响应
3. 三个 Boss 可被击败，卢恩与装备掉落生效
4. 赐福：休息回满 HP/耐力、升级消耗卢恩、传送至已解锁赐福
5. 死亡：失去部分卢恩、在最近赐福复活、卢恩堆可拾取
6. `docs/superpowers/plans/2026-07-01-voxsoul-playtest-notes.md` 手动 checklist **≥80% 勾选**

### 1.3 本 Sprint 明确不做

- Boss / 敌人 mesh 动画替换
- 锁定目标时的相机环绕（仅朝向目标）
- 招式 telegraph 美术与音效
- 新区域、NPC、叙事
- 弹反窗口 / 前摇 / 伤害数值的手感调参（仅保证链路通）

---

## 2. 地图与路线

### 2.1 统一高度常量

新增共享常量（`voxsoul_world/constants.lua` 或等效模块）：

| 常量 | 值 | 说明 |
|------|-----|------|
| `FLOOR_Y` | `20` | 全 Demo 地面节点 Y |
| `SPAWN` | `(0, 21, 0)` | 玩家脚点，站在 `FLOOR_Y` 草方块顶面 |

`spawn.lua` 与 `map_builder.lua` **必须**引用同一常量，禁止各自硬编码不同 Y。

### 2.2 地图重建策略

- 存储键：`voxsoul:map_version`，当前目标值 `"2"`
- 若 world mod_storage 中版本 ≠ `"2"`，执行 `voxsoul.world.build_map()` 并写入新版本
- 移除仅依赖 `voxsoul:map_built == "1"` 的一次性逻辑，避免旧世界保留 y=10 地图

### 2.3 路线结构

全图在 `FLOOR_Y = 20`：

```
教程废墟 (0,0) ──金纹路──► 大树守卫 (80,0) ──► 风暴关/玛尔基特 (160,0) ──► 接肢墓 (215,50)
      ↑ gatefront 赐福              ↑ sentinel 赐福           ↑ margit 赐福              ↑ hag 赐福
```

### 2.4 关键坐标（建造后验证）

| 要素 | 位置 (x, y, z) |
|------|----------------|
| 出生 / 教程牌 | `(0, 21, 0)` / 牌 `(0, 21, 3)` |
| Gatefront 赐福 | `(0, 20, 8)` |
| 大树守卫刷新 | `(80, 21, 0)` |
| 玛尔基特刷新 | `(160, 21, 0)` |
| 接肢鬼婆刷新 | `(230, 21, 50)` |
| 普通敌兵（示例） | 道路中段，Y = `FLOOR_Y + 1` |

所有 `voxsoul_grace.register`、`enemy_spawns`、Boss `spawn()` 调用必须与上表一致。

### 2.5 连通性要求

- 每段 `build_road` 与 arena `set_floor` 地板在 XZ 平面连续，相邻区域无 ≥2 格宽的不可通过缺口
- 教程区 `ensure_spawn_pad` 合并为废墟区地板的一部分，不再维护独立「天空高台」与主地图分离的逻辑
- 地牢区（接肢墓）允许低于 `FLOOR_Y` 的内部结构，但入口 floor 与道路齐平

---

## 3. 战斗与系统阻塞项

### 3.1 HP 统一

- **唯一权威**：`voxsoul.combat.ensure_data(player).hp`
- HUD、死亡、赐福休息均读写 combat HP
- 加入时：`player:set_hp(20)` 满足引擎占位；`register_on_player_hpchange` 返回 `true` 阻止引擎默认伤害改血（或等效方案）
- 战斗伤害只走 `voxsoul.combat.apply_damage_to_player`

### 3.2 锁定目标

- **主键**：`Z`（Luanti `player:get_player_control().zoom`）
- **后备**：聊天命令 `/lockon`（保留）
- 行为：`toggle_lockon`；锁定时每 tick `set_look_horizontal` 朝向目标；超出 `LOCKON_BREAK_RANGE` 取消
- **不做**：相机环绕、strafe 模式

### 3.3 伤害链路

| 方向 | 路径 |
|------|------|
| 玩家 → 敌人/Boss | `perform_attack` → `resolve_attack_hit` → `apply_damage_to_entity` |
| Boss → 玩家 | Boss AI 活跃帧 → `voxsoul.combat.hit_entity_with_attack` 或 `apply_damage_to_player` |
| 玩家死亡 | combat `hp <= 0` → `voxsoul.player.on_death` |

实现后需在 playtest notes 中记录：轻攻击对骑士/Boss 扣血、Boss 招式对玩家扣血。

### 3.4 卢恩与死亡

- 死亡损失：`voxsoul.player.stats.death_rune_loss`
- 卢恩堆：`voxsoul_world:rune_pile` 右键/靠近拾取（现有 punch 逻辑）
- 复活：`on_death` 延迟传送至 `last_grace`，HP/耐力回满

### 3.5 HUD 警告（低优先级）

- 将 `hud_elem_type` 改为 `type`（Luanti 5.16），本 Sprint 顺手修复，不单独成 task

---

## 4. 实施阶段

| 阶段 | 内容 | 交付 |
|------|------|------|
| **A1** | 共享 `FLOOR_Y`、map_version=2 重建、坐标对齐 | 可走通全程 |
| **A2** | HP 统一、Z 锁定、伤害链路验证与补洞 | 可打死/被打死 |
| **A3** | 手动 playtest + bugfix | 更新 playtest-notes，≥80% checklist |
| **A4** | README 操作表（Z 锁定）、实现计划文档 | 见 `plans/2026-07-01-voxsoul-playability-sprint.md` |

---

## 5. 测试

### 5.1 自动

- 现有 `voxsoul_tests` 全部保持 PASS
- 可选：断言 `voxsoul.world.FLOOR_Y == 20` 且 `map_version` 键存在

### 5.2 手动（摘自原 spec §10.2）

- [ ] 教程牌与操作响应
- [ ] 闪避无敌帧（目视/i-frame 日志）
- [ ] 格挡与弹反有反馈（不要求手感合格）
- [ ] 大树守卫、玛尔基特（含阶段 2）、接肢鬼婆可击败
- [ ] 赐福休息/升级/传送
- [ ] 死亡复活与卢恩堆拾取
- [ ] 第三人称越肩全程有效
- [ ] 从出生沿路到最终 Boss 无软锁

---

## 6. 风险与回退

| 风险 | 缓解 |
|------|------|
| 旧世界 map 缓存导致不重建 | 强制 `map_version` 比对；文档说明删除 `mod_storage` 或新建世界 |
| Boss AI 不攻击玩家 | A2 专门验证并补 `on_step` 伤害调用 |
| Z 键与引擎 zoom 冲突 | README 注明；settings 中可改键 |

---

## 7. 参考文件

- `games/voxsoul/mods/voxsoul_world/map_builder.lua`
- `games/voxsoul/mods/voxsoul_world/spawn.lua`
- `games/voxsoul/mods/voxsoul_combat/`
- `games/voxsoul/mods/voxsoul_boss/init.lua`
- `docs/superpowers/plans/2026-07-01-voxsoul-playtest-notes.md`
