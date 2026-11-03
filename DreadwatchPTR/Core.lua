-- DreadwatchPTR v0.2.0 - targeted Forever capability diagnostics
-- Never register speculative encounter events or log raw combat payloads.
local addonName = ...
local frame = CreateFrame("Frame")
local prefix = "|cffb57affDreadwatch PTR|r "
local db
local counts, sample = {}, {spell={}, npc={}, secret=0, restricted=0, readable=0}
local events = {"PLAYER_ENTERING_WORLD","ZONE_CHANGED_NEW_AREA","PLAYER_REGEN_DISABLED","PLAYER_REGEN_ENABLED","UNIT_SPELLCAST_START","UNIT_SPELLCAST_SUCCEEDED","UNIT_SPELLCAST_INTERRUPTED"}
local function say(s) if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage(prefix..s) end end
local function safe(v)
  if type(issecretvalue)=="function" then
    local ok, secret = pcall(issecretvalue,v)
    if not ok or secret then return false end
  end
  if type(canaccessvalue)=="function" then
    local ok, allowed = pcall(canaccessvalue,v)
    if not ok or not allowed then return false end
  end
  return true
end
local function readable(v)
  if not safe(v) then sample.restricted=sample.restricted+1; return false end
  sample.readable=sample.readable+1
  return true
end
local function initialize()
  if type(DreadwatchPTRDB)~="table" then DreadwatchPTRDB={} end
  db=DreadwatchPTRDB
  if type(db.schema)~="number" then db.schema=1 end
  if type(db.launchCount)~="number" then db.launchCount=0 end
  if type(db.records)~="table" then db.records={} end
  db.launchCount=db.launchCount+1
end
local function namespace(n) return type(_G[n]) end
local function status()
  local version,build,_,iface=GetBuildInfo()
  say("Client "..tostring(version).." build "..tostring(build).." interface "..tostring(iface))
  say("WOW_PROJECT_ID="..tostring(WOW_PROJECT_ID))
  for _,n in ipairs({"C_Secrets","C_EncounterEvents","C_EncounterTimeline","C_EncounterWarnings","C_EncounterInfo","C_ChatInfo","C_AddOnProfiler","C_Timer","C_UnitAuras","C_Spell"}) do
    say(n.."="..namespace(n))
  end
  say("Secret helpers: issecretvalue="..type(issecretvalue).." issecrettable="..type(issecrettable).." canaccessvalue="..type(canaccessvalue))
  say("Event probe mode: conservative; unsupported encounter events NOT registered")
  say("SavedVariables: schema="..tostring(db.schema).." loads="..tostring(db.launchCount).." marker="..tostring(db.marker or "none"))
end
local function record(event,...)
  counts[event]=(counts[event] or 0)+1
  if not sample.enabled then return end
  if event=="UNIT_SPELLCAST_START" or event=="UNIT_SPELLCAST_SUCCEEDED" or event=="UNIT_SPELLCAST_INTERRUPTED" then
    local unit,castGUID,spellID=...
    -- Only inspect values after secret/access checks; no raw payload retained.
    if readable(unit) and type(unit)=="string" and (unit=="target" or unit=="focus" or unit=="player" or unit:match("^boss%d+$")) then
      local ok,guid=pcall(UnitGUID,unit)
      if ok and readable(guid) and type(guid)=="string" then
        local id=guid:match("^Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)%-") or guid:match("^Vehicle%-%d+%-%d+%-%d+%-%d+%-(%d+)%-")
        if id and #sample.npc<12 then sample.npc[id]=true end
      end
    end
    if readable(spellID) and type(spellID)=="number" and spellID>0 and spellID<10000000 then sample.spell[spellID]=true end
    -- castGUID intentionally not inspected or persisted.
  end
end
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
for _,e in ipairs(events) do frame:RegisterEvent(e) end
frame:SetScript("OnEvent",function(_,event,...)
  if event=="ADDON_LOADED" then
    local name=...
    if safe(name) and name==addonName then initialize(); say("Loaded. /dwptr help for commands") end
  elseif event=="PLAYER_LOGIN" then
    if db then status() end
  else record(event,...) end
end)
local function listSamples(label,t)
  local out={}
  for id in pairs(t) do out[#out+1]=tostring(id) end
  table.sort(out)
  if #out==0 then say(label..": none observed") else
    local limit=math.min(#out,12)
    local v={}
    for i=1,limit do v[i]=out[i] end
    say(label.." ("..#out.."): "..table.concat(v,", ")..(#out>limit and " ..." or ""))
  end
end
SLASH_DREADWATCHPTR1="/dwptr"
SlashCmdList.DREADWATCHPTR=function(raw)
  local cmd,arg=(raw or ""):match("^(%S*)%s*(.-)%s*$")
  if cmd=="" or cmd=="help" then
    say("Commands: status, events, scan, test combat, report, marker TEXT, reset, help")
  elseif cmd=="status" then status()
  elseif cmd=="events" then
    for _,e in ipairs(events) do say(e.." observed "..tostring(counts[e] or 0).." times") end
    say("Encounter events: NOT REGISTERED (pending instance verification)")
  elseif cmd=="scan" then
    say("Targeted scan: namespaces are availability only, not proof of callable APIs")
    for _,n in ipairs({"C_Secrets","C_EncounterEvents","C_EncounterTimeline","C_EncounterWarnings","C_Spell","C_UnitAuras","C_ChatInfo"}) do say(n.."="..namespace(n)) end
    say("Combat event delivery previously verified on build 70707; see /dwptr events")
    say("Encounter payloads, boss mechanics and addon sync: UNVERIFIED")
  elseif cmd=="test" and arg=="combat" then
    sample.enabled=true
    sample.spell={};sample.npc={};sample.restricted=0;sample.readable=0
    say("Combat diagnostic enabled for this session. Fight an NPC, then /dwptr report")
  elseif cmd=="report" then
    say("Capability Lab v0.2.0; test enabled="..tostring(sample.enabled or false))
    listSamples("Safe spell IDs",sample.spell)
    listSamples("Safe NPC IDs",sample.npc)
    say("Accessible checks="..sample.readable.." restricted/unknown checks="..sample.restricted)
    say("Boss encounter events: UNVERIFIED; not registered to avoid taint")
    say("Addon messaging: UNVERIFIED; no packets transmitted")
    say("Results are runtime-only; no combat payloads saved")
  elseif cmd=="marker" then
    if arg=="" or #arg>80 then say("Usage: /dwptr marker TEXT (1-80 chars)") else db.marker=arg; say("Marker set") end
  elseif cmd=="reset" then
    counts={};sample={spell={},npc={},restricted=0,readable=0}
    say("Runtime diagnostics cleared; SavedVariables preserved")
  else say("Unknown command; /dwptr help") end
end
