# VoxSoul

Elden Ring 风格的 souls-like Luanti 子游戏（非官方同人项目）。

## 前置要求

- Luanti **5.13+**（本仓库已包含便携版 5.16.1，见下方「快速启动」）
- Windows 10/11

## 快速启动（便携 Luanti）

仓库内已下载 Luanti 5.16.1 便携版，并完成子游戏联接：

```powershell
# 启动 Luanti 客户端
& "D:\Z\game\VoxSoul\tools\luanti\luanti-5.16.1-win64\bin\luanti.exe"

# 或启动专用服务器（联调 / 多人）
& "D:\Z\game\VoxSoul\tools\luanti\luanti-5.16.1-win64\bin\luanti.exe" `
  --server --world "D:\Z\game\VoxSoul\games\voxsoul\worlds\demo_interlude" --gameid voxsoul
```

**首次进入游戏：**

1. 启动客户端 → **开始游戏** → 选择世界 **demo_interlude**（或新建，游戏选 **VoxSoul**）
2. 控制台应出现全部 `[voxsoul_tests] ... passed` 与 `[voxsoul_world] Demo map build complete`（仅首次建图）
3. 出生点：引导废墟 `(0, 11, 0)`

## 操作

| 输入 | 动作 |
|------|------|
| LMB | 轻攻击 |
| Shift + LMB | 重攻击 |
| RMB | 格挡 |
| Space + 方向 | 闪避 |
| E (aux1) | 赐福交互 |
| `/lockon` | 锁定目标 |
| `/voxsoul unstuck` | 传送到最近赐福 |

## Demo 地图路线

```
引导废墟 → 门旁赐福 → 开阔道(大树守卫) → 风暴赐福
→ 玛尔基特 → 关卡后赐福 → 接肢墓(鬼婆)
```

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
- 贴图为 16×16 占位 PNG，可替换为正式美术
- 详见 `docs/superpowers/specs/2026-07-01-voxsoul-elden-design.md`

## 同人项目声明

详见 [games/voxsoul/FAN_PROJECT.md](games/voxsoul/FAN_PROJECT.md)。
