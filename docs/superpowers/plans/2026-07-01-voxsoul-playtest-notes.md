# VoxSoul Playtest Notes

Date: 2026-07-01
Environment: Luanti not installed on dev machine — static implementation only

## Automated assertions (on mod load)

- [x] voxsoul_tests core + camera + integration smoke
- [x] voxsoul_entity hitbox
- [x] voxsoul_combat stamina/state/dodge
- [x] voxsoul_player stats
- [x] voxsoul_boss ai pick_attack

## Server integration (Luanti 5.16.1 portable)

- [x] All mods load without ModError
- [x] Demo map auto-build on first run
- [x] Mapgen aliases registered (flat)

## Manual checklist (requires in-game client)

- [ ] Tutorial sign readable
- [ ] Third-person over-shoulder locked
- [ ] Light/heavy attack via LMB / Shift+LMB
- [ ] Dodge i-frames
- [ ] Block and parry window
- [ ] Tree Sentinel, Margit phase 2, Grafted Hag defeatable
- [ ] Grace rest/upgrade/travel
- [ ] Death rune loss and pickup
- [ ] Full demo 1-2 hours

## Known gaps

- Placeholder sprite textures (replace PNGs in mod `textures/` folders)
- Q lock-on uses `/lockon` chatcommand
- Client-side combat feel not yet manually verified in GUI session
