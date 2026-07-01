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

- Boss/敌人仍为 sprite，非 mesh
- 锁定无相机环绕
- 弹反/手感未调参

---

## Sprint B — UI & Animation (2026-07-01)

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
