# VoxSoul Agent Loop

**Mode:** polish-only (85% code gate met)  
**Wake delay:** 30s one-shot heartbeat after each turn  
**Sentinel:** `AGENT_LOOP_WAKE_voxsoul`

## Prompt (each tick)

继续 VoxSoul 艾尔登法环对标开发：读取 `docs/superpowers/specs/2026-07-01-voxsoul-elden-roadmap.md` 与 `.superpowers/sdd/progress.md`，执行下一未完成高优先级任务，headless 验证，commit push，更新完成度，无需询问用户。完成后立即进入下一轮（arm 3s wake）。

## Stop

Kill the tracked sleeper PID or delete this file and ask agent to stop loop.
