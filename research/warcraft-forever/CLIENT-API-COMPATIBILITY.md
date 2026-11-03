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
