# VoxSoul — 艾尔登法环对标路线图（自主迭代）

**日期**：2026-07-01  
**状态**：Approved（自主维护，无需用户 gate）  
**目标**：Demo「宁姆格福残页」整体体验接近 v1 设计 spec（`2026-07-01-voxsoul-elden-design.md`）  
**度量**：下方任务清单 + playtest checklist 完成率

---

## 总体完成度（2026-07-01 基线）

| 维度 | 权重 | 完成度 | 说明 |
|------|------|--------|------|
| P0 战斗手感 | 25% | **86%** | 锁定 strafe + 动画节奏 |
| P1 Boss 战 | 25% | **90%** | 葛瑞克二阶段 |
| P2 探索/地图 | 20% | **88%** | 史东薇尔片段 map v4 |
| P3 成长/装备 | 15% | **75%** | loadout HUD |
| UI/反馈/叙事 | 15% | **95%** | lore + 中文赐福 |
| **加权合计** | 100% | **~91%** | Limgrave→Godrick 代码验收 |

**放行门槛（自主定义）**：加权 ≥90%，playtest ≥85%，Boss 链至葛瑞克（见 `2026-07-01-voxsoul-limgrave-godrick-loop-design.md`）。

---

## 任务队列（按优先级）

### Phase C — 战斗完整度（当前）

| ID | 任务 | 优先级 | 状态 | 完成度 |
|----|------|--------|------|--------|
| **C1** | 普通敌人近战 AI（骑士/接肢怪追击+攻击） | P0 | **完成** | 100% |
| **C2** | 锁定目标 HP 条 + 名称 HUD | P0 | **完成** | 100% |
| **C3** | 卢恩堆 E 键拾取（死亡循环） | P0 | **完成** | 100% |
| **C4** | 弹反/格挡视觉与音效反馈 | P0 | **完成** | 100% |
| **C5** | 锁定软跟随相机（yaw/pitch 向目标） | P0 | **完成** | 100% |
| **C6** | 受击屏幕闪红 + hitstop 0.05s | P1 | **完成** | 100% |

### Phase D — Boss 与流程

| ID | 任务 | 优先级 | 状态 | 完成度 |
|----|------|--------|------|--------|
| **D1** | Boss 脱战 5s 回满 HP | P1 | **完成** | 100% |
| **D2** | 招式 telegraph（前摇粒子/蹲伏） | P1 | **完成** | 100% |
| **D3** | 大树守卫护符掉落 | P2 | **完成** | 100%（golden_blessing +5 HP） |
| **D4** | Demo 通关 UI / 统计 | P2 | **完成** | 100% |

### Phase E — 法环体感 polish

| ID | 任务 | 优先级 | 状态 | 完成度 |
|----|------|--------|------|--------|
| **E1** | Boss/敌人 mesh（或 improved sprite） | P2 | **完成** | 100% |
| **E2** | 锁定移动 strafe 环绕 | P2 | **完成** | 100% |
| **E3** | 战斗动画 b3d 专用帧（Mixamo） | P3 | **部分** | 70%（现有 b3d 节奏调优；Mixamo 帧 deferred） |
| **E4** | 法环风 UI 贴图 | P3 | **完成** | 100% |

---

## Spec 自主确认记录

| 文档 | 决议 |
|------|------|
| `2026-07-01-voxsoul-elden-design.md` | **Approved**；锁定键改为 **Z (zoom)**；跳跃 **Space**、闪避 **Space+方向** |
| Sprint A/B specs | 已实施，归档 |
| 本 roadmap | 迭代主 spec，每轮 loop 更新完成度 |

---

## 每轮 Loop 工作流（自主）

**模式**：无定时间隔；每轮完成后 **3 秒** 唤醒下一轮（配置见 `.superpowers/loop.md`）。

1. 读取本文件与 `playtest-notes.md`
2. 取最高优先级「待做」任务
3. 实现 → headless 测试 → commit → push
4. 更新本表完成度与加权合计
5. 若 ≥85% 且 checklist ≥90%，进入 polish-only；否则 **立即** 继续 Phase D/E

---

## 参考

- 主设计：`docs/superpowers/specs/2026-07-01-voxsoul-elden-design.md`
- Playtest：`docs/superpowers/plans/2026-07-01-voxsoul-playtest-notes.md`
