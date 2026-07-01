# VoxSoul Playtest Notes

Date: 2026-07-01
Environment: Luanti not installed on dev machine — static implementation only

## Automated assertions (on mod load)

- [x] voxsoul_tests core + camera
- [x] voxsoul_entity hitbox
- [x] voxsoul_combat stamina/state/dodge
- [x] voxsoul_player stats
- [x] voxsoul_boss ai pick_attack

## Manual checklist (requires Luanti 5.13+)

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

- Placeholder sprite textures (need PNG assets in mod textures/)
- Map is coordinate-based spawns; full voxel map not hand-built yet
- Q lock-on uses `/lockon` chatcommand alias until key binding added
- Dig/place blocked via punchnode + item override
