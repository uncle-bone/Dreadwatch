-- Dreadwatch PTR Diagnostics v0.1.0-ptr
-- Read-only probes. Never log restricted event payloads or secret values.
local addonName = ...
local frame = CreateFrame("Frame")
local prefix = "|cffb57affDreadwatch PTR|r "
local registered = {}
local logLimit = 120
local runtime = { counts = {}, events = {}, session = 0 }
local function say(msg)
  if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage(prefix .. tostring(msg)) end
end
local function persist()
  if type(DreadwatchPTRDB) ~= "table" then DreadwatchPTRDB = {} end
  local db = DreadwatchPTRDB
  if type(db.schema) ~= "number" then db.schema = 1 end
  if type(db.launchCount) ~= "number" then db.launchCount = 0 end
  if type(db.records) ~= "table" then db.records = {} end
  return db
end
local function safeType(root, key)
  local ok, result = pcall(function()
    if type(root) ~= "table" then return "namespace missing" end
    return type(root[key])
  end)
  return ok and result or "restricted"
end
local candidates = {
  "ENCOUNTER_START", "ENCOUNTER_END", "INSTANCE_ENCOUNTER_ENGAGE_UNIT",
  "BOSS_KILL", "PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA",
  "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_SUCCEEDED", "UNIT_SPELLCAST_INTERRUPTED",
  "COMBAT_LOG_EVENT_UNFILTERED", "ENCOUNTER_TIMELINE_EVENT",
  "ENCOUNTER_WARNING", "ENCOUNTER_EVENT",
}
local function probeEvents()
  for _, name in ipairs(candidates) do
    if not registered[name] then
      local ok = pcall(frame.RegisterEvent, frame, name)
      registered[name] = ok and "registered" or "unavailable"
    end
  end
end
local function report()
  local version, build, _, iface = GetBuildInfo()
  say("Client " .. tostring(version) .. " build " .. tostring(build) .. " interface " .. tostring(iface))
  say("WOW_PROJECT_ID=" .. tostring(WOW_PROJECT_ID) .. "; combat=" .. tostring(InCombatLockdown and InCombatLockdown() or false))
  local namespaces = {
    {"C_Secrets", C_Secrets}, {"C_EncounterEvents", C_EncounterEvents},
    {"C_EncounterTimeline", C_EncounterTimeline}, {"C_EncounterWarnings", C_EncounterWarnings},
    {"C_EncounterInfo", C_EncounterInfo}, {"C_ChatInfo", C_ChatInfo},
    {"C_AddOnProfiler", C_AddOnProfiler}, {"C_Timer", C_Timer},
  }
  for _, entry in ipairs(namespaces) do
    say(entry[1] .. "=" .. type(entry[2]))
  end
  say("Secret helpers: issecretvalue=" .. type(issecretvalue) .. " issecrettable=" .. type(issecrettable) .. " canaccessvalue=" .. type(canaccessvalue))
  for _, name in ipairs(candidates) do say("Event " .. name .. ": " .. tostring(registered[name] or "not probed")) end
  local db = persist()
  say("SavedVariables: schema=" .. tostring(db.schema) .. " launches=" .. tostring(db.launchCount) .. " marker=" .. tostring(db.marker or "none"))
end
local function record(event, ...)
  runtime.counts[event] = (runtime.counts[event] or 0) + 1
  local n = select("#", ...)
  local row = { event=event, count=n }
  -- No event payloads recorded: fields may be secret or sensitive.
  if #runtime.events >= logLimit then table.remove(runtime.events, 1) end
  table.insert(runtime.events, row)
  if event == "ENCOUNTER_START" or event == "ENCOUNTER_END" or event == "BOSS_KILL" then
    say(event .. " observed (payload omitted)")
  end
end
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(_, event, ...)
  if event == "ADDON_LOADED" then
    local name = ...
    if name == addonName then
      local db = persist()
      db.launchCount = db.launchCount + 1
      probeEvents()
      say("Loaded. /dwptr help for commands")
    end
  elseif event == "PLAYER_LOGIN" then
    report()
  else
    record(event, ...)
  end
end)
SLASH_DREADWATCHPTR1 = "/dwptr"
SlashCmdList.DREADWATCHPTR = function(raw)
  local cmd, arg = (raw or ""):match("^(%S*)%s*(.-)%s*$")
  if cmd == "help" or cmd == "" then
    say("Commands: status, events, marker TEXT, reset, help")
  elseif cmd == "status" then
    report()
  elseif cmd == "events" then
    for _, name in ipairs(candidates) do
      local n = runtime.counts[name] or 0
      if n > 0 then say(name .. " observed " .. tostring(n) .. " times") end
    end
    say("Runtime event rows=" .. tostring(#runtime.events) .. " (never saved)")
  elseif cmd == "marker" then
    if arg == "" then say("Usage: /dwptr marker YOUR_TEXT") return end
    if #arg > 80 then say("Marker too long (max 80 characters)") return end
    persist().marker = arg
    say("Marker set. Test /reload, logout and cold restart.")
  elseif cmd == "reset" then
    runtime.counts, runtime.events = {}, {}
    say("Runtime counters cleared; SavedVariables preserved")
  else
    say("Unknown command; use /dwptr help")
  end
end
