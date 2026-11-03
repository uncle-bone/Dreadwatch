# Dreadwatch — unresolved research gaps

Updated 2026-11-03. Do not treat missing evidence as confirmed absence.

## Highest priority: runtime feasibility
1. Verify launch build, TOC interface and Lua version from live client.
2. Capture allowed encounter start/end, boss cast, unit aura, target and combat events; document secret-value behavior.
3. Determine whether Blizzard encounter timer information is accessible to addons.
4. Verify addon-to-addon messaging restrictions in instances.
5. Verify SavedVariables persistence and protected UI operations in combat.

## Content inventory
- Authoritative Warcraft Forever dungeon and raid roster, availability and release dates.
- Instance IDs, difficulties and level/player requirements.
- Boss names, NPC IDs, encounter IDs and phase boundaries.
- Spell IDs, mechanic behavior and difficulty variants.
- Reliable timings from live logs or authoritative scripts.
- World bosses, events, optional encounters and release status.

## Engineering
- Decide event-driven encounter identification based on verified API.
- Specify timers with evidence tiers; do not fabricate exact cooldowns.
- Determine whether learning is technically possible under combat-data restrictions.
- Define communication protocol only after verifying messaging.
- Implement replay tests with clearly marked synthetic fixtures.
- Benchmark CPU, memory, timer update and UI performance in raid conditions.

## Evidence collection template
For each claim record: claim, source URL, source revision/date, retrieval date, evidence classification (LIVE VERIFIED / SOURCE VERIFIED / HISTORICAL / INFERRED / UNRESOLVED), game build, confidence, and conflicting evidence.

## Research sources to inspect
- https://github.com/Thunderz96/forever-addon-kit
- https://github.com/mparke/forever-addons
- Official Warcraft Forever patch notes and addon developer statements
- Forever-tagged boss mods on CurseForge and GitHub
- Public encounter guides, footage, combat logs and accessible server scripts

No live Warcraft Forever combat log has yet been supplied to this research baseline.
