# VoxSoul Limgrave → Godrick Loop

**Status:** armed (awaiting spec Approved)  
**Mode:** milestone-gated M0–M5  
**Wake delay:** 5s one-shot after each turn  
**Sentinel:** `AGENT_LOOP_WAKE_limgrave`

## Spec

`docs/superpowers/specs/2026-07-01-voxsoul-limgrave-godrick-loop-design.md`

## Progress

`.superpowers/progress-limgrave.md`

## Prompt (each tick)

继续 VoxSoul 宁姆格福→葛瑞克 Loop：读取 docs/superpowers/specs/2026-07-01-voxsoul-limgrave-godrick-loop-design.md、.superpowers/progress-limgrave.md、.superpowers/loop-limgrave.md。执行当前里程碑最高优先级待做任务；对照 .superpowers/deviation-log.md 纠正法环偏差；headless 验证；commit push；更新进度。M5 完成后停止 loop。无需询问用户。

## Stop

M5 验收完成，或用户要求停止。Kill sleeper PID；将 Status 改为 stopped。
