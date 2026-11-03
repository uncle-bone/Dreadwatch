# Dreadwatch PTR test plan (v0.1.0-ptr)
Date: 2026-11-03. **Unverified in-game**; designed for safe, read-only reconnaissance.

## Installation
Download the `DreadwatchPTR/` directory from the repository, retaining the folder layout. Place the directory directly in the PTR client's `Interface/AddOns/` folder (not inside another nested directory). Enable at character select. The TOC declares interface 16001; confirm `/dwptr status` reports the actual PTR build/interface before trusting the results.

## Commands
- `/dwptr help`: list commands.
- `/dwptr status`: client build, interface, project ID, namespace availability, event registration results, persistence marker.
- `/dwptr events`: counts of observed event names (no combat payloads).
- `/dwptr marker test-one`: store an innocuous marker in SavedVariables.
- `/dwptr reset`: clear only in-memory counters.

## Test matrix
1. Login; screenshot or copy `/dwptr status`. Record version/build and registration failures.
2. `/dwptr marker test-one`, then `/reload`, then `/dwptr status`. Confirm marker remains.
3. Fully exit client and restart; confirm marker remains. Repeat after switching characters.
4. Enter combat against ordinary NPCs; run `/dwptr events` afterward. Note observed event counts. Do not attempt to stringify secret combat payloads.
5. Enter a PTR dungeon/raid, start and finish a boss encounter; capture `/dwptr events` and any ENCOUNTER_START/END chat notifications.
6. Test wipe and reset; check for repeated or missing encounter events.
7. Test party/raid, zone transitions, death, logout, reload. Capture any Lua errors and their full stack traces.
8. Check UI behavior with other addons disabled, then with installed boss mods enabled. Do not infer compatibility from presence alone.

## Interpretation and safety
- `registered` means the event name was accepted, **not** that it fired or that its payload is readable.
- `namespace=table` means the namespace exists, **not** that individual functions are callable.
- Event payloads are intentionally never inspected or stored; this cannot yet verify boss/spell IDs, cast timing, phases, or secrets.
- No addon messages are sent; no group data is collected; no protected actions are attempted.
- No encounter mechanic/timer is marked verified until a separate controlled live observation supports it.
- SavedVariables launchCount increases on each addon load (including /reload), not only fresh game launches.
- If the addon fails to load, capture the exact error and PTR build. Do not patch with old Classic APIs blindly.

## Next probes after baseline passes
Implement opt-in, narrowly scoped API-signature probes and encounter event payload inspection only when allowed by the PTR's combat secrecy restrictions. Build a replay fixture from sanitized, permitted observations, then implement Dreadwatch encounter engine and warnings.


## v0.2.0 targeted capability lab (2026-11-03)
Source implementation committed; NOT yet tested on live client.
- `/dwptr scan`: checks researched namespaces, no speculative event registration.
- `/dwptr test combat`: opt-in in-memory spell-ID and creature GUID/NPC-ID observations from known spellcast events; never sends addon messages or stores combat payloads in SavedVariables.
- `/dwptr report`: shows accessible spell/NPC IDs, restricted checks, and unverified boss/sync status.
- `/dwptr events`: known-safe event counts; encounter events intentionally not registered.
- `/dwptr marker test-one`: existing persistent marker retained.
Open-world procedure: run scan; run test combat; fight a hostile NPC and cast spells; run report and events; capture any taint/Lua errors. Absence of an NPC ID in this opt-in sample does not imply that GUID APIs are unavailable.
Dungeon boss testing is deferred until dungeon access becomes available. Encounter APIs remain namespace-presence only, NOT confirmed boss signals.
