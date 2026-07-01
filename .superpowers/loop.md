# VoxSoul Agent Loop

**Mode:** polish-only (85% code gate met)  
**Wake delay:** 30s one-shot heartbeat after each turn  
**Sentinel:** `AGENT_LOOP_WAKE_voxsoul`

## Prompt (each tick)

VoxSoul polish-only（85% 已达成）：更新 playtest-notes、README 操作表，修复小缺口，headless 验证，commit push。无高优先级任务时 arm 60s wake 或停止 loop。

## Stop

Kill the tracked sleeper PID or delete this file and ask agent to stop loop.
