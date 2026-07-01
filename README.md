# VoxSoul

Elden Ring 风格的 souls-like Luanti 子游戏（非官方同人项目）。

## 前置要求

- [Luanti](https://www.luanti.org/)（原 Minetest）已安装
- Windows PowerShell（用于创建目录联接）

## 目录结构

```
games/voxsoul/
├── game.conf              # 子游戏配置
├── FAN_PROJECT.md         # 同人项目声明
├── mods/
│   └── voxsoul_core/      # 核心 mod（全局 voxsoul 表）
└── worlds/
    └── demo_interlude/    # 示例世界配置
```

## 链接到 Luanti

Luanti 会从用户目录下的 `games/` 文件夹加载子游戏。将本仓库中的 `games/voxsoul` 链接到 Luanti 用户目录即可，无需复制整个仓库。

### Windows（目录联接）

在 PowerShell 中执行（请将路径替换为你的实际路径）：

```powershell
$LuantiUser = "$env:APPDATA\Luanti"
$RepoGame   = "D:\Z\game\VoxSoul\games\voxsoul"

# 确保 Luanti games 目录存在
New-Item -ItemType Directory -Force -Path "$LuantiUser\games" | Out-Null

# 创建目录联接（需管理员权限或开发者模式）
New-Item -ItemType Junction -Path "$LuantiUser\games\voxsoul" -Target $RepoGame
```

若 `$env:APPDATA\Luanti` 尚不存在，请先启动 Luanti 一次以生成用户目录，再执行上述命令。

### Linux / macOS（符号链接）

```bash
ln -s /path/to/VoxSoul/games/voxsoul ~/.local/share/luanti/games/voxsoul
```

（Luanti 用户目录因平台而异，请以实际安装位置为准。）

## 验证加载

1. 启动 Luanti
2. 创建新世界 → 选择子游戏 **VoxSoul**
3. 进入世界后，在控制台或日志中应看到：

   ```
   [voxsoul_core] Loading VoxSoul 0.1.0-dev
   ```

4. 无报错即表示脚手架加载成功

## 开发说明

- 当前仅启用 `voxsoul_core` mod；其余 mod 将在后续任务中逐步添加并在 `game.conf` 中启用
- 全局命名空间：`voxsoul = {}`，版本号见 `voxsoul.VERSION`
- 示例世界配置位于 `worlds/demo_interlude/world.mt`

## 同人项目声明

详见 [games/voxsoul/FAN_PROJECT.md](games/voxsoul/FAN_PROJECT.md)。本项目与 FromSoftware、Bandai Namco 无任何关联，仅供个人或小范围使用，请勿商业化。
