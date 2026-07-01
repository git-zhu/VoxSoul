# VoxSoul — 宁姆格福→史东薇尔→葛瑞克 Loop 迭代设计

**日期**：2026-07-01  
**状态**：Approved  
**前置**：`2026-07-01-voxsoul-elden-design.md`（Approved）、`2026-07-01-voxsoul-elden-roadmap.md`（Phase C–E 完成）  
**Loop 配置**：`.superpowers/loop-limgrave.md`

---

## 1. 目标与验收

### 1.1 目标

在 **非 1:1 复刻** 前提下，将 Demo 推进至 **宁姆格福 + 史东薇尔城可探索片段**，Boss 链对齐法环主线至 **接肢葛瑞克**，并通过自主 **Loop** 持续打磨至高度相似。

### 1.2 验收标准（Loop 停止条件）

| # | 标准 |
|---|------|
| A1 | 路线可通：引导 → 门旁赐福 → 开阔道（大树守卫可选）→ 玛尔基特 → 雾墙门外赐福 → 史东薇尔城门 → 城庭 →（侧路可选）→ 接肢大厅 → **葛瑞克王座** |
| A2 | Boss 可稳定击败：大树守卫（可选）、玛尔基特（必打）、**葛瑞克（必打，二阶段）** |
| A3 | 赐福 ≥5，含 2 个新城内赐福，显示名为法环风中文 |
| A4 | `grafted_hag` 退役；终局为 `godrick`；通关 UI 提及大卢恩 |
| A5 | 加权完成度 ≥**90%**（本 spec §6 量表）；playtest checklist ≥**85%** |
| A6 | headless 测试全 pass；每里程碑 commit + push |

### 1.3 明确不做

- 候王礼拜堂序章、接肢贵族后裔（Grafted Scion）  
- 啜泣半岛、利耶尼亚、联机、NPC 对话树  
- 1:1 复制史东薇尔全城或葛瑞克全招式集  

---

## 2. 法环偏差纠正清单

Loop 每轮开始前读取本表；发现新偏差则追加一行并优先修复。

| ID | 现状 | 目标 | 里程碑 |
|----|------|------|--------|
| D1 | 终局 Boss `grafted_hag` / 接肢鬼婆 | `godrick` / 接肢葛瑞克 | M3 |
| D2 | `build_catacombs()` 接肢墓 | `build_stormveil_slice()` | M1–M2 |
| D3 | 英文 Grace 名 | 法环风中文（§2.4 表） | M1 |
| D4 | 通关 UI 接肢鬼婆文案 | 葛瑞克 + 大卢恩 | M3 |
| D5 | `MAP_VERSION=2` | `MAP_VERSION=3` | M1 |
| D6 | 侧路/城内探索不足 | 侧廊 + 2 赐福 + 城内敌人 | M2 |
| D7 | 玛尔基特后直连地牢 | 史东薇尔城门 → 城庭 → 大厅 | M1 |

---

## 3. 地图架构（`map_version=3`）

### 3.1 主线坐标（FLOOR_Y=20）

```
引导废墟 (0,0)
  → 门旁赐福
  → 开阔道 / 大树守卫 (~80,0)
  → 风暴关卡 / 玛尔基特 (~160,0)
  → 雾墙门外赐福 (~170,5)
  → 史东薇尔城门 (~185,0)
  → 城庭 (~205,0)
  → 接肢大厅 (~240,10)
  → 葛瑞克王座 (~255,15)
```

### 3.2 侧路（C 档探索）

| 区块 | 坐标 | 内容 |
|------|------|------|
| 侧翼回廊 | X 200–225, Z -35~-15 | 砖墙走廊、失乡骑士 ×1、环境文本 |
| 城厢赐福 | ~210, -25 | `stormveil_side` |
| 大厅前赐福 | ~235, 8 | `stormveil_hall` |

城庭 (~205,0) 分岔；侧路不硬锁，主线可直达葛瑞克。

### 3.3 体素与氛围

- 外墙/走廊：`dark_brick` + `gold_trim`  
- 城庭：略下沉 + 围墙  
- 王座房：加高空间 + 地面金边  
- 环境：`lore_sign` 或复用 `tutorial_sign`，中文短句（致敬向，非剧情脚本）

### 3.4 赐福表

| ID | 显示名 | 解锁 |
|----|--------|------|
| `gatefront` | 引导门前赐福 | 默认 |
| `stormhill` | 风暴山头赐福 | 靠近 |
| `after_margit` | 雾墙门外赐福 | 击败玛尔基特 |
| `stormveil_side` | 史东薇尔侧室赐福 | 靠近（新） |
| `stormveil_hall` | 接肢大厅赐福 | 靠近（新） |

`catacombs` 赐福 **退役**。

### 3.5 敌人

| 区域 | 实体 | 数量 |
|------|------|------|
| 开阔道 | `voxsoul_world:knight` | 2 |
| 城庭 | `voxsoul_world:omen_freak` | 2 |
| 侧廊 | `voxsoul_world:knight` | 1 |
| 大厅 | `voxsoul_world:omen_freak` | 2 |

Boss 生成：`godrick` @ (255, sy, 15)。

---

## 4. Boss：接肢葛瑞克（`godrick`）

**文件**：`games/voxsoul/mods/voxsoul_boss/bosses/godrick.lua`  
**精灵**：`voxsoul_boss_godrick.png`（`tools/gen_entity_sprites.py` 扩展）

| 属性 | 值 |
|------|-----|
| 名称 | 接肢葛瑞克 |
| max_hp | 1800 |
| max_poise | 100 |
| runes | 5000 |
| 掉落 | meta `voxsoul:great_rune:godrick`；可选护符占位 |

### 4.1 阶段 1（HP > 50%）

| 招式 | windup | damage | hitbox |
|------|--------|--------|--------|
| `axe_sweep` | 0.8s | 38 | arc r=3.5, 100° |
| `wind_gust` | 1.0s | 28 | arc r=4, 120° |
| `leap_slam` | 1.3s | 52 | circle r=3 |
| `kneel_shock` | 1.5s | 45 | circle r=4 |

### 4.2 阶段 2（HP ≤ 50%）

- 过渡：`boss_phase` 闪屏 + chat「见证吧！接肢的艺术！」；名称后缀「— 龙焰形态」  
- 攻击池：`fire_sweep`, `fire_slam`, `striding_flame`, `axe_sweep`（权重见实现计划）

| 招式 | windup | damage | hitbox |
|------|--------|--------|--------|
| `fire_sweep` | 1.2s | 42 | arc r=5, 90° |
| `fire_slam` | 1.0s | 48 | circle r=3.5 |
| `striding_flame` | 1.4s | 35 | arc r=6, 45° |

### 4.3 通关

- `voxsoul.boss.on_defeated("godrick", player)` → `show_demo_clear`（葛瑞克/大卢恩文案）  
- 移除 `grafted_hag` 注册与生成；旧存档 `voxsoul:boss:grafted_hag` 可忽略  

---

## 5. Loop 专用任务书（里程碑门禁）

**编排方案**：里程碑门禁 Loop（§1 推荐方案 1）。  
**唤醒**：每轮结束后 **3s** one-shot（`.superpowers/loop-limgrave.md`）。  
**哨兵**：`AGENT_LOOP_WAKE_limgrave`

### 5.1 里程碑

| ID | 名称 | 完成条件 |
|----|------|----------|
| **M0** | Spec 落地 | 本 spec Approved；`loop-limgrave.md` 就绪；`deviation-log` 初始化 |
| **M1** | 史东薇尔外廓 | `MAP_VERSION=3`；`build_stormveil_slice` 城门+城庭+主线连通；赐福中文名；D3/D5/D7 关闭 |
| **M2** | 城内探索 | 侧廊+2 赐福+敌人部署；D6 关闭；map 无软锁 |
| **M3** | 葛瑞克 Boss | `godrick.lua`+精灵+生成点；二阶段；通关 UI；D1/D4 关闭；退役 `grafted_hag` |
| **M4** | 法环 polish | 环境 lore 文本 ≥3 处；playtest 代码验证项更新；手感/数值微调 |
| **M5** | 验收 | A1–A6 全部满足；loop 停止 |

### 5.2 任务队列（Loop 每轮取当前里程碑最高优先级「待做」）

#### M1

| Task | 内容 |
|------|------|
| M1-T1 | `constants.lua`：`MAP_VERSION = "3"` |
| M1-T2 | `map_builder.lua`：删除 catacombs；新增 `build_stormveil_gate/courtyard` |
| M1-T3 | `grace/init.lua`：赐福中文名 + 注册 `stormveil_side/hall`（位置占位） |
| M1-T4 | 道路：玛尔基特后 (~181+) 改接 Stormveil 而非 catacombs |

#### M2

| Task | 内容 |
|------|------|
| M2-T1 | `build_stormveil_side_path` 侧廊体素 |
| M2-T2 | 赐福节点放置 + travel 菜单可见 |
| M2-T3 | `enemy_spawns` 城庭/侧廊/大厅 |
| M2-T4 | `lore_sign` 或 tutorial 文本 ≥2 条 |

#### M3

| Task | 内容 |
|------|------|
| M3-T1 | `bosses/godrick.lua` 数据表 |
| M3-T2 | `gen_entity_sprites.py` → `voxsoul_boss_godrick.png` |
| M3-T3 | `init.lua`：注册 godrick；移除 grafted_hag；生成点 (255,15) |
| M3-T4 | `on_defeated` / `show_demo_clear` 葛瑞克文案 |
| M3-T5 | 阶段 2 过渡 chat + `boss_phase` 闪屏 |

#### M4

| Task | 内容 |
|------|------|
| M4-T1 | 更新 `playtest-notes.md` + `README.md` 路线 |
| M4-T2 | 新完成度量表填充分数 |
| M4-T3 | 战斗/数值微调（可选，仅当 checklist 缺口） |

### 5.3 每轮 Loop 工作流

1. 读 `loop-limgrave.md`、本 spec、`progress-limgrave.md`、deviation-log  
2. 读 `2026-07-01-voxsoul-elden-design.md`；若有输入/命名偏差，先纠正  
3. 取 **当前里程碑** 首个「待做」任务  
4. 实现 → headless 验证 → 更新 progress → commit → push  
5. 里程碑 checklist 全绿 → 进入下一里程碑；**M5 完成 → 停止 loop**  
6. Arm 3s wake（除非已停止）

### 5.4 Loop Prompt（写入 `loop-limgrave.md`）

```
继续 VoxSoul 宁姆格福→葛瑞克 Loop：读取 docs/superpowers/specs/2026-07-01-voxsoul-limgrave-godrick-loop-design.md、.superpowers/progress-limgrave.md、.superpowers/loop-limgrave.md。执行当前里程碑最高优先级待做任务；对照 deviation-log 纠正法环偏差；headless 验证；commit push；更新进度。M5 完成后停止 loop。无需询问用户。
```

### 5.5 自主资源查询

允许 loop 使用 web 查询法环 Boss 招式、中文名、区域 lore，**仅作致敬参考**；实现以本 spec 招式表为准，避免侵权复制长文本。

---

## 6. 完成度量表（目标 ≥90%）

| 维度 | 权重 | 基线 | M5 目标 |
|------|------|------|---------|
| P0 战斗手感 | 25% | 84% | 88% |
| P1 Boss 战 | 25% | 82% | 92% |
| P2 探索/地图 | 20% | 55% | 90% |
| P3 成长/装备 | 15% | 72% | 80% |
| UI/反馈/叙事文本 | 15% | 94% | 95% |
| **加权合计** | 100% | ~79% | **≥90%** |

---

## 7. 测试

- 每轮：headless server，`[voxsoul_*] passed` 无 ModError  
- M1 后：确认 `map_version=3` 日志  
- M3 后：`voxsoul.boss.registry.godrick` assert；`grafted_hag` 不存在  
- M5：playtest checklist 人工项标注「待实机」

---

## 8. 文件清单

| 路径 | 动作 |
|------|------|
| `.superpowers/loop-limgrave.md` | 新建 Loop 配置 |
| `.superpowers/progress-limgrave.md` | 新建里程碑进度 |
| `.superpowers/deviation-log.md` | 新建偏差跟踪 |
| `docs/superpowers/specs/2026-07-01-voxsoul-limgrave-godrick-loop-design.md` | 本 spec |
| `games/voxsoul/mods/voxsoul_world/map_builder.lua` | 改 |
| `games/voxsoul/mods/voxsoul_world/constants.lua` | 改 |
| `games/voxsoul/mods/voxsoul_grace/init.lua` | 改 |
| `games/voxsoul/mods/voxsoul_boss/bosses/godrick.lua` | 新建 |
| `games/voxsoul/mods/voxsoul_boss/bosses/grafted_hag.lua` | 删除或归档 |
| `tools/gen_entity_sprites.py` | 扩展 |

---

## 9. Spec 自主确认

| 项 | 决议 |
|----|------|
| 验收 Boss | 接肢葛瑞克（A） |
| 地图范围 | 史东薇尔可探索片段（C） |
| Loop 编排 | 里程碑门禁 M0–M5 |
| 终局 | 替换 grafted_hag |
| 状态 | **Approved**（2026-07-01） |
