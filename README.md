# VoxSoul

Elden Ring 风格的 souls-like Luanti 子游戏（非官方同人项目）。

## 前置要求

- Luanti **5.13+**（本仓库已包含便携版 5.16.1，见下方「快速启动」）
- Windows 10/11

## 快速启动（便携 Luanti）

仓库内已下载 Luanti 5.16.1 便携版，并完成子游戏联接：

**推荐启动：**

```powershell
D:\Z\game\VoxSoul\play-voxsoul.bat
```

**手动启动（便携 Luanti）：**

```powershell
& "D:\Z\game\VoxSoul\tools\luanti\luanti-5.16.1-win64\bin\luanti.exe" `
  --world "D:\Z\game\VoxSoul\games\voxsoul\worlds\demo_interlude" --gameid voxsoul --go
```

**地图版本：** Demo 使用 `map_version=4`（史东薇尔片段）。若地形异常，删除 `games/voxsoul/worlds/demo_interlude/mod_storage/voxsoul_core` 后重启；控制台应出现 `Demo map v4 build complete`。

## 操作

| 输入 | 动作 |
|------|------|
| LMB | 轻攻击 |
| Shift + LMB | 重攻击 |
| RMB | 格挡 |
| Space | 跳跃 |
| Space + 方向 | 闪避（消耗耐力，带位移） |
| E (aux1) | 赐福交互 / 拾取卢恩堆 |
| Z (zoom) | 锁定目标 |
| `/lockon` | 锁定目标（聊天命令） |
| `/voxsoul unstuck` | 传送到最近赐福 |

**地图版本：** 见上方「快速启动」说明。

- 左下：法环风 HP / 耐力 statbar + 数值
- 右下：卢恩数、当前武器与护符
- Boss 战：顶部 Boss 名 + 血条（阶段切换金色闪屏）
- Z 锁定：目标脚下红圈；WASD 相对目标 strafe 环绕

## Demo 地图路线（宁姆格福 → 史东薇尔 → 葛瑞克）

```
引导废墟 → 引导门前赐福 → 开阔道(大树守卫) → 风暴山头赐福
→ 恶兆玛尔基特 → 雾墙门外赐福 → 史东薇尔城门 → 城庭
→ [侧路: 史东薇尔侧室赐福] → 接肢大厅赐福 → 接肢葛瑞克
```

**验收 Boss 链：** 大树守卫（可选）→ 玛尔基特 → **接肢葛瑞克**（二阶段，通关）

## 链接到系统 Luanti（可选）

若已安装 Luanti 到 `%APPDATA%\Luanti`：

```powershell
New-Item -ItemType Junction -Path "$env:APPDATA\Luanti\games\voxsoul" -Target "D:\Z\game\VoxSoul\games\voxsoul"
```

便携版联接路径（已配置）：

```
D:\Z\game\VoxSoul\tools\luanti\luanti-5.16.1-win64\games\voxsoul → 仓库 games/voxsoul
```

## 联调验证结果（2026-07-01）

- Luanti 5.16.1 服务器加载 **10 个 mod** 无 ModError
- 自动测试全部通过（core / camera / hitbox / combat / player / boss / integration）
- 体素 Demo 地图首次启动自动构建（`map_builder.lua`）

## 开发说明

- 全局命名空间 `voxsoul = {}`；持久化使用 `minetest.get_mod_storage()`
- 贴图使用 CC0 手绘 Minetest 包（drummyfish / OpenGameArt），可用 `python tools/install_textures.py` 重新安装
- 玩家模型：`voxsoul_tarnished.b3d` + CC0 骑士皮肤（isaiah658 / OpenGameArt Skin_27），可用 `python tools/install_player_model.py` 重新安装
- UI 纹理：`python tools/gen_ui_textures.py`；敌人/Boss 精灵：`python tools/gen_entity_sprites.py`
- 自主迭代 loop：`.superpowers/loop-limgrave.md`（Limgrave→Godrick，3s wake）
- 设计 spec：`docs/superpowers/specs/2026-07-01-voxsoul-limgrave-godrick-loop-design.md`

## 同人项目声明

详见 [games/voxsoul/FAN_PROJECT.md](games/voxsoul/FAN_PROJECT.md)。
