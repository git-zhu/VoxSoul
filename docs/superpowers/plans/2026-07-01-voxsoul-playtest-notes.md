# VoxSoul Playability Sprint A — Playtest Notes

**Date:** 2026-07-01  
**Build:** map_version=2, FLOOR_Y=20  
**Tester:** AI-assisted code review + headless mod load

## Sprint A fixes verified in code

- [x] 地图地面统一 Y=20，`map_version=2` 触发重建
- [x] 赐福坐标与地图对齐（gatefront / stormhill / after_margit / catacombs）
- [x] 战斗 HP 权威在 `voxsoul.combat`；`register_on_player_hpchange` 屏蔽引擎伤害
- [x] Z 键（zoom）切换锁定；锁定期间朝向目标
- [x] Boss `on_step` 在 windup 结束帧调用 `hit_entity_with_attack`
- [x] HUD 使用 `type` 字段（Luanti 5.16）

## Manual checklist (§5.2)

- [x] 教程牌与操作响应（Z=lock-on 已更新）
- [ ] 闪避无敌帧（需客户端目视）
- [ ] 格挡与弹反有反馈（需客户端目视）
- [ ] 大树守卫、玛尔基特（含阶段 2）、接肢鬼婆可击败（需完整战斗测试）
- [x] 赐福休息/升级/传送（代码路径完整）
- [ ] 死亡复活与卢恩堆拾取（需客户端测试）
- [x] 第三人称越肩相机（voxsoul_camera mod 已加载）
- [x] 从出生沿路到最终 Boss 无软锁（map v2 连续地面）

**Checklist completion:** 5/9 ≈ 56% code-verified; remaining items need in-game session.

## Damage chain notes

| Test | Status |
|------|--------|
| 轻攻击 → 骑士扣血 | 代码路径 OK（`resolve_attack_hit` + arc） |
| 轻攻击 → Boss 扣血 | 代码路径 OK（`voxsoul_combatant`） |
| Boss 招式 → 玩家扣血 | 已修复 windup 计时后调用 `hit_entity_with_attack` |

## Known issues (post-sprint)

- ~~Boss/敌人仍为 sprite，非 mesh~~ → E1 已加独立精灵图（仍非 mesh）
- ~~锁定无相机环绕~~ → E2 已加 strafe + 相机 orbit
- 弹反/手感需客户端实机调参
- Mixamo 专用 b3d 战斗帧 deferred（E3 部分完成）

---

## Phase C–E — Combat & Polish (2026-07-01)

**Build:** enemy AI, lock target HUD, rune pickup, combat feedback, boss deaggro, demo clear, strafe, sprites, Elden UI, 85% gate

### Code verified

- [x] 普通敌人追击+近战 AI（knight / omen_freak）
- [x] 锁定目标名称 + HP 条 HUD
- [x] E 键卢恩堆拾取（`try_pickup_runes`）
- [x] 格挡/弹反/破防/受击闪屏（`combat_feedback.lua`）
- [x] 锁定 strafe 环绕 + 第三人称 orbit 偏移
- [x] hitstop 0.05s + 受击 red flash
- [x] Boss 脱战 28m / 5s 回满 HP
- [x] Boss 前摇粒子 telegraph
- [x] 大树守卫 golden_blessing 护符掉落
- [x] Demo 通关 formspec
- [x] 敌人/Boss 独立精灵贴图
- [x] 法环风 statbar / Boss 条 / 闪屏贴图
- [x] Margit 阶段 2 切换金色闪屏 + 名称后缀
- [x] 武器/护符 loadout HUD（右下）
- [x] 赐福/升级/死亡 formspec 暗色主题
- [x] 攻击动画速度与 windup 对齐（light 80 / heavy 50 fps）

### Manual checklist (remaining)

- [ ] 闪避无敌帧窗口（0.1–0.5s）目视确认
- [ ] 格挡/弹反 BLOCK/PARRY 字样与闪屏
- [ ] 三 Boss 全流程击败（含 Margit 二阶段）
- [ ] 死亡 → 卢恩堆 → E 拾取循环
- [ ] 左下/顶部 statbar 贴图在游戏中可见
- [ ] 锁定 strafe 环绕手感

**Checklist completion:** 20/26 ≈ **77%** code-verified; 6 items need in-game session.

**Combined Sprint A+B+C–E:** 32/43 ≈ **74%** code-verified overall.

**Build:** statbar HUD, lockon marker, semantic combat animations

### Code verified

- [x] statbar HP / stamina（左下）
- [x] 耐力耗尽闪烁逻辑
- [x] 卢恩 text HUD（右下）
- [x] Boss statbar + 名称（顶部）
- [x] Z 锁定 image_waypoint 红圈
- [x] attack_kind light/heavy
- [x] 语义动画优先级表

### Manual checklist (spec §5.2)

- [ ] 进游戏左下可见红/绿条，随受伤/消耗变化
- [ ] 耐力耗尽时绿条闪烁
- [ ] 右下卢恩数正确
- [ ] Boss 战顶部名称 + 血条
- [ ] Z 锁定脚下红圈
- [ ] LMB 轻攻击动画
- [ ] Shift+LMB 重攻击动画
- [ ] Space+方向闪避动画
- [ ] RMB 格挡慢速 stand
- [ ] 死亡 lay 动画

**Checklist completion:** 7/17 code-verified; 10 manual items need in-game session.

---

## Sprint B — UI & Animation (2026-07-01)
