# Dreadwatch prelaunch research and PTR readiness
Date: 2026-11-03. Status: source research complete for initial probe; live PTR verification pending.

## Repository audit
On inspection of main before this update, repository contained README.md and two research files: CLIENT-API-COMPATIBILITY.md, UNRESOLVED-RESEARCH-GAPS.md. No gameplay addon core, boss modules, timers, warning engine, release assets or tags were found. We have now added separate read-only DreadwatchPTR diagnostic addon and test plan. Do not confuse the probe with a functional Dreadwatch boss mod.

## Client and addon API evidence
- WoW Forever uses interface 16001, product wowf on current build 70707 according to ForeverPlusPlus local inspection; beta documentation often uses wow_classic_beta and _classic_beta_, which should not be copied as current install path.
- WOW_PROJECT_ID reports WOW_PROJECT_MAINLINE, so Retail project detection alone cannot identify Forever.
- Retail-derived C_* API with modern combat secrets; old Wrath CLEU and global spell/auras APIs cannot be assumed.
- Atraeau APIDocumentation snapshot build 70170: 6,598 functions, 1,806 events, 797 types. C_EncounterEvents, C_EncounterTimeline, C_EncounterWarnings, C_EncounterInfo are documented namespaces, not validated Dreadwatch hooks.
- Thunderz first-week beta captured build 69893 and reported secret auras, restricted CLEU, 100-error cap, early SavedVariables cold-restart failure; secure snippets reportedly fixed build 70009. Test against current PTR rather than applying stale workarounds.
Sources:
https://github.com/Atraeau/WoW-Addons/blob/main/docs/api/README.md
https://github.com/Thunderz96/forever-addon-kit
https://github.com/xIGBClutchIx/ForeverPlusPlus/blob/main/docs/forever-api.md
https://github.com/Gethe/wow-ui-source/tree/forever

## Existing encounter data in FWoW-Research
- 35 dungeon/raid catalog files, 311 named boss/NPC rows, 201 rows with encounter IDs, 215 distinct encounter IDs, 279 explicit NPC IDs.
- Cross-reference of 24 DBM-Forever module registrations: 24 matched by encounter ID, but no boss-specific warnings/timers/spell handlers established.
- Encounter IDs and NPC IDs must be provenance-tagged; do not assume every catalog boss is currently playable.
Source: https://github.com/uncle-bone/FWoW-Research/tree/main/research/local-client-scans/2026-11-03

## PTR proof gates
1. Confirm live build, interface, TOC loading, and namespaces with /dwptr status.
2. Verify event name registration and event firing separately.
3. Verify SavedVariables across /reload, logout, full restart, character swap.
4. Verify instance and encounter event behavior with real encounters; do not print secret payloads.
5. Only then develop a permission-safe, opt-in encounter event recorder and event replay fixtures.
6. Build warning/timer architecture only on events that the PTR actually exposes and permits.

## Known gaps
- No direct PTR execution performed. No actual encounter events or mechanics verified.
- Need exact encounter event payload signatures and whether usable in combat; C_Encounter* namespace existence is insufficient.
- Need map/instance/difficulty IDs, phase/cast timings and spell mechanics confirmed in live data.
- Need sync API, SavedVariables, Lua runtime and secure UI tests.
- Need research registries with explicit confidence and source revision; existing FWoW-Research JSON can be reconciled after inspecting full data.
- No install-ready ZIP or GitHub release published for this diagnostic probe. Repository folder is source-only.

## Next implementation milestone
After PTR results: Dreadwatch core with capability-gated encounter detector, configurable nonsecret warning sources, modular bosses, conservative timer scheduler, no speculative exact timers, test fixtures and performance budgets. Learning/sync must be opt-in and validated, with bounded storage and schema versions.
