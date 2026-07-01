# Limgrave → Godrick Loop Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace catacombs/grafted_hag with Stormveil slice + Godrick final boss; milestone-gated loop until M5 acceptance.

**Architecture:** Bump `MAP_VERSION=3` to rebuild map via `map_builder.lua` modular builders; add graces/enemies in `voxsoul_world` + `voxsoul_grace`; new `godrick.lua` boss data; retire `grafted_hag`. Loop reads `progress-limgrave.md` each tick.

**Tech Stack:** Luanti 5.16.1, Lua mods, headless server test, `play-voxsoul.bat` for manual playtest.

## Global Constraints

- `FLOOR_Y=20`; spawn via `voxsoul.world.SPAWN`
- Boss framework: `voxsoul.boss.register`, entity `voxsoul_boss:entity`
- Grace: `voxsoul.grace.register(id, { name, pos })`
- Commit + push each milestone task group; headless must show `[voxsoul_*] passed`
- Loop wake: **3s** sentinel `AGENT_LOOP_WAKE_limgrave`
- 启动游戏用 `play-voxsoul.bat`

---

### Task 1: M1 — MAP_VERSION + Stormveil gate/courtyard

**Files:**
- Modify: `games/voxsoul/mods/voxsoul_world/constants.lua`
- Modify: `games/voxsoul/mods/voxsoul_world/map_builder.lua`
- Modify: `games/voxsoul/mods/voxsoul_grace/init.lua`

**Interfaces:**
- Produces: `voxsoul.world.MAP_VERSION = "3"`, `build_stormveil_gate()`, `build_stormveil_courtyard()`

- [ ] **Step 1:** Set `MAP_VERSION = "3"` in constants.lua
- [ ] **Step 2:** Remove `build_catacombs()`; add gate (~185,0) + courtyard (~205,0) + hall stub (~240,10)
- [ ] **Step 3:** Grace Chinese names; register `stormveil_side`, `stormveil_hall` (positions placeholder OK)
- [ ] **Step 4:** Reroute road post-Margit to gate (remove catacombs road)
- [ ] **Step 5:** Headless test; commit `feat(world): map v3 stormveil gate and courtyard`

---

### Task 2: M2 — Side path + enemies + lore

**Files:**
- Modify: `games/voxsoul/mods/voxsoul_world/map_builder.lua`
- Modify: `games/voxsoul/mods/voxsoul_world/init.lua`

- [ ] **Step 1:** `build_stormveil_side_path()` Z -35~-15 corridor
- [ ] **Step 2:** Place grace nodes at (210,-25) and (235,8)
- [ ] **Step 3:** Enemy spawns courtyard/side/hall per spec §3.5
- [ ] **Step 4:** Add 2+ lore tutorial_sign texts (Chinese)
- [ ] **Step 5:** Headless test; commit `feat(world): stormveil side path and spawns`

---

### Task 3: M3 — Godrick boss

**Files:**
- Create: `games/voxsoul/mods/voxsoul_boss/bosses/godrick.lua`
- Delete: `games/voxsoul/mods/voxsoul_boss/bosses/grafted_hag.lua`
- Modify: `games/voxsoul/mods/voxsoul_boss/init.lua`
- Modify: `games/voxsoul/mods/voxsoul_ui/hud.lua`
- Modify: `tools/gen_entity_sprites.py`

- [ ] **Step 1:** Create godrick.lua with phases/attacks per spec §4
- [ ] **Step 2:** Generate `voxsoul_boss_godrick.png`
- [ ] **Step 3:** Register godrick; spawn (255,sy,15); remove grafted_hag; on_defeated → demo_clear
- [ ] **Step 4:** Phase 2 chat + name suffix
- [ ] **Step 5:** Headless + boss ai assert; commit `feat(boss): Godrick replaces grafted hag`

---

### Task 4: M4 — Docs + metrics

**Files:**
- Modify: `docs/superpowers/plans/2026-07-01-voxsoul-playtest-notes.md`
- Modify: `README.md`
- Modify: `.superpowers/deviation-log.md`

- [ ] **Step 1:** Update route, boss names, grace list
- [ ] **Step 2:** Close deviation-log items; update completion table
- [ ] **Step 3:** Commit `docs: limgrave godrick playtest and readme`

---

### Task 5: M5 — Acceptance

- [ ] **Step 1:** Verify A1–A6 in progress-limgrave.md
- [ ] **Step 2:** Set loop-limgrave.md Status: stopped
- [ ] **Step 3:** Final commit if needed
