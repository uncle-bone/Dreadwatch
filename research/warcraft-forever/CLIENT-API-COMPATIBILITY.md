# Warcraft Forever — Dreadwatch API compatibility baseline

Status: research baseline, **not live-client verified by Dreadwatch**. Updated 2026-11-03.

## Source-backed beta findings
- Warcraft Forever beta uses modern/Mainline-derived addon architecture rather than the WoW 3.3.5a Lua/API assumptions.
- Beta interface number reported as **16001**, on the 1.60.1 build line. Re-check against launch client before shipping.
- Beta tooling reported `WOW_PROJECT_ID == WOW_PROJECT_MAINLINE`; avoid treating that alone as proof of Retail gameplay rules.
- Modern namespaced APIs (`C_Spell`, `C_Item`, `C_Traits`) replace many Classic global API assumptions.
- Midnight-era secret-value and combat restrictions reportedly apply. Do not assume legacy combat-log event access, GUID parsing, or instance addon messaging.
- Beta TOC variants reported: `_Camelot.toc` and `_Forever.toc`; verify supported suffix and interface value in live launch client.

## Primary code/research references
- https://github.com/Thunderz96/forever-addon-kit — beta API captures, porting tools and compatibility experiments; snapshot dated September 2026.
- https://github.com/mparke/forever-addons — API probe, lint, test tooling and example addons.
- https://warcraft.wiki.gg/wiki/TOC_format — manifest format; verify Forever-specific changes.
- https://forevermeta.me/en/guides/wow-forever-addons-interface — secondary reporting on combat restrictions and beta changes.

## Dreadwatch design consequences
1. Do **not** implement a 3.3.5a COMBAT_LOG_EVENT_UNFILTERED engine without live proof that Forever exposes suitable events.
2. Separate encounter evidence from runtime detection: a timer should carry provenance and confidence.
3. Probe actual encounter and unit events, combat secret-value handling, instance detection, timer APIs and communication limits before choosing the boss engine.
4. Do not make raid synchronization a required dependency; instance messaging may be restricted.
5. Treat historical boss mechanics as candidates until matched against Warcraft Forever encounters.

## Launch-client verification required
- `GetBuildInfo()` version/build/interface, `WOW_PROJECT_ID`, and actual TOC suffix handling.
- Lua version and availability of `C_Spell`, `C_UnitAuras`, `C_ChatInfo`, `C_InstanceInfo` and timer facilities.
- Which events fire during boss combat, and which payload fields are secret.
- Availability of encounter start/end signals and usable boss-mod timer data.
- Whether addon messages can be sent and received in party, raid and instances.
- SavedVariables persistence and load ordering.
- Installation folder, final launch interface number and archive structure.

## Evidence classifications
SOURCE VERIFIED means demonstrated by cited source revision, **not** live verified on launch. INFERRED means plausible design consequence. UNRESOLVED means live evidence absent.

Current Dreadwatch live verification: **UNRESOLVED**. No boss IDs, spell IDs or exact timers are asserted here.


## PTR observations supplied by user (2026-11-03; build 70707)
Evidence: copied live in-game /dwptr output, not automated CI. Version 1.60.1, interface 16001, WOW_PROJECT_ID=18.
- LIVE VERIFIED: C_Secrets, C_EncounterEvents, C_EncounterTimeline, C_EncounterWarnings, C_ChatInfo, C_AddOnProfiler, C_Timer, C_UnitAuras, C_Spell namespace values are tables; C_EncounterInfo is nil.
- LIVE VERIFIED: issecretvalue, issecrettable and canaccessvalue are functions. Individual protected values and their permitted uses are NOT verified.
- LIVE VERIFIED: PLAYER_REGEN_DISABLED=1, PLAYER_REGEN_ENABLED=1, UNIT_SPELLCAST_START=7, UNIT_SPELLCAST_SUCCEEDED=11, UNIT_SPELLCAST_INTERRUPTED=2 after open-world combat.
- LIVE VERIFIED: SavedVariables marker test-one persisted across /reload and full client restart; launchCount progressed from 9 to 10.
- LIVE VERIFIED: v0.1.0 speculative pcall-based event registrations caused taint (taint.log showed Core.lua:37 probeEvents). User confirmed the protected-action popup ceased after conservative v0.1.1 test build.
- UNVERIFIED: spell ID / NPC GUID field accessibility, secret-value behavior during combat, encounter event payloads, boss mechanics, addon messaging in instances, actual launch build.
- SOURCE VERIFIED: FWoW-Research contains 35 instance journal files, 311 named catalog rows, 215 distinct encounter IDs and 24 matching DBM-Forever modules. These are not live mechanics.

DreadwatchPTR v0.2.0 source introduces targeted, opt-in capability diagnostics, but this new version is NOT YET LIVE TESTED. No encounter event registration or network transmission is performed.
