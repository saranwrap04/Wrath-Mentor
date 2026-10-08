-- Wrath Mentor - Core (v2)
-- Client: WoW 3.3.5a (Interface 30300). Lua 5.1, no modern APIs.

local ADDON_NAME = ... -- the addon's folder name (WrathMentor, or Wrath-Mentor-main from GitHub)
WrathMentor = WrathMentor or {}
local WM = WrathMentor
WM.folder = ADDON_NAME or "WrathMentor"
WM.media = "Interface\\AddOns\\" .. WM.folder .. "\\textures\\"

WM.version = "3.4.1"
WM.raids = {}        -- raids[id] = { id, name, zones, bosses, src }
WM.raidOrder = {}    -- display order
WM.nameIndex = {}    -- lowercase NPC name -> boss entry
WM.selected = nil    -- boss currently shown in the main window

local DEFAULTS = {
    role = "ALL",                -- ALL | TANK | HEAL | DPS
    size = 25,                   -- 10 or 25 (which raid size the text is written for)
    announce = true,             -- post a chat line (with a clickable link) when you target a boss
    announceRaidOnly = true,     -- only announce inside raid instances
    modelsEnabled = true,        -- allow the 3D Model view
    sendContent = "strategy",    -- what "Send to chat" sends: strategy | hard | tldr
    mainScale = 1.0,             -- tactics window size (UI scale slider)
    mainWidth = 760,             -- tactics window width (drag-to-resize corner)
    mainHeight = 500,            -- tactics window height (drag-to-resize corner)
    mainAlpha = 1.0,             -- tactics window opacity (0 to 1)
    minimap = { hide = false, angle = 225 },
    notes = {},                  -- personal notes, keyed by "<raid>:<boss name>"
}
WM.DEFAULTS = DEFAULTS

local ROLE_KEY = { TANK = "tank", HEAL = "heal", DPS = "dps" }
local ROLE_NAME = { ALL = "All", TANK = "Tank", HEAL = "Healer", DPS = "DPS" }

local function lower(s) return string.lower(s or "") end

------------------------------------------------------------------
-- Data registration (called by the Data_*.lua files)
------------------------------------------------------------------
function WM:AddRaid(id, name, zones, bosses, src)
    local raid = { id = id, name = name, zones = zones or {}, bosses = bosses, src = src }
    self.raids[id] = raid
    table.insert(self.raidOrder, id)
    for i, boss in ipairs(bosses) do
        boss.raidId = id
        boss.index = i
        self.nameIndex[lower(boss.name)] = boss
        if boss.aliases then
            for _, alias in ipairs(boss.aliases) do
                self.nameIndex[lower(alias)] = boss
            end
        end
    end
end

function WM:BossKey(boss)
    return boss.raidId .. ":" .. boss.name
end

function WM:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cfffc7a2bWrath Mentor:|r " .. tostring(msg))
end

------------------------------------------------------------------
-- Saved variables
------------------------------------------------------------------
local function CopyDefaults(src, dst)
    for k, v in pairs(src) do
        if type(v) == "table" then
            if type(dst[k]) ~= "table" then dst[k] = {} end
            CopyDefaults(v, dst[k])
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
end

-- Clickable in-chat link that opens this boss's guide. Uses a private "addon:"
-- hyperlink type intercepted by the hooks below - never a real item/spell link,
-- so it can't be confused with (or accidentally trigger) anything else. The
-- link data is the raid id + boss index (never the boss name), since a name
-- can contain spaces/apostrophes that some clients handle unreliably inside
-- a hyperlink's data segment - keeping it to plain identifiers is the safest bet.
function WM:BossLink(boss)
    local data = "addon:WrathMentor:" .. boss.raidId .. ":" .. boss.index
    return "|cff71d5ff|H" .. data .. "|h[Shift-click to open " .. boss.name .. "'s guide]|h|r"
end

function WM:BossFromLink(link)
    local raidId, index = string.match(link or "", "^addon:WrathMentor:([^:]+):(%d+)$")
    if not raidId then return nil end
    local raid = self.raids[raidId]
    if not raid then return nil end
    return raid.bosses[tonumber(index)]
end

-- Which raids are expanded in the boss list. NOT saved to disk - every raid
-- starts collapsed again each session; only stays open for the rest of that
-- session (or until the raid holding your current boss auto-expands).
WM.collapsed = {}

function WM:Init()
    WrathMentorDB = WrathMentorDB or {}
    CopyDefaults(DEFAULTS, WrathMentorDB)
    if WrathMentorDB.size ~= 10 and WrathMentorDB.size ~= 25 then WrathMentorDB.size = 25 end
    self.db = WrathMentorDB
    self.collapsed = {}
    for _, id in ipairs(self.raidOrder) do self.collapsed[id] = true end
    self:Print("v" .. self.version .. " loaded. Type /wm to open, /wm help for commands.")
end

-- Restore every option to its default (positions, role, size and notes are left alone)
function WM:ResetOptions()
    local d = DEFAULTS
    self.db.announce = d.announce
    self.db.announceRaidOnly = d.announceRaidOnly
    self.db.modelsEnabled = d.modelsEnabled
    self.db.sendContent = d.sendContent
    self.db.mainScale = d.mainScale
    self.db.mainAlpha = d.mainAlpha
    self.db.minimap.hide = d.minimap.hide
    self.db.minimap.angle = d.minimap.angle
    self:ApplySettings()
end

------------------------------------------------------------------
-- Lookups
------------------------------------------------------------------
function WM:GetZoneRaid()
    local zone = GetRealZoneText()
    if not zone or zone == "" then return nil end
    for _, id in ipairs(self.raidOrder) do
        local raid = self.raids[id]
        for _, z in ipairs(raid.zones) do
            if z == zone then return raid end
        end
    end
    return nil
end

function WM:FindBossByUnit(unit)
    if not UnitExists(unit) or UnitIsPlayer(unit) then return nil end
    if not IsInInstance() then return nil end
    local name = UnitName(unit)
    if not name then return nil end
    return self.nameIndex[lower(name)]
end

function WM:FindBoss(query)
    query = lower(query)
    if query == "" then return nil end
    if self.nameIndex[query] then return self.nameIndex[query] end
    for _, id in ipairs(self.raidOrder) do
        for _, boss in ipairs(self.raids[id].bosses) do
            if string.find(lower(boss.name), query, 1, true) then return boss end
            if boss.aliases then
                for _, a in ipairs(boss.aliases) do
                    if string.find(lower(a), query, 1, true) then return boss end
                end
            end
        end
    end
    return nil
end

------------------------------------------------------------------
-- 10 / 25 man text expansion
--   "[10] text"   -> shown only when 10-man is selected
--   "[25] text"   -> shown only when 25-man is selected
--   "#{a/b}"      -> "a" in 10-man, "b" in 25-man
------------------------------------------------------------------
function WM:GetSize()
    return (self.db and self.db.size) or 25
end

function WM:Expand(line)
    if type(line) ~= "string" then return nil end
    local size = self:GetSize()
    local tag, rest = string.match(line, "^%[(%d+)%]%s*(.*)$")
    if tag then
        if tonumber(tag) ~= size then return nil end
        line = rest
    end
    line = string.gsub(line, "#{([^/}]*)/([^}]*)}", function(a, b)
        if size == 10 then return a end
        return b
    end)
    return line
end

function WM:ExpandList(list)
    local out = {}
    if list then
        for _, l in ipairs(list) do
            local e = self:Expand(l)
            if e and e ~= "" then out[#out + 1] = e end
        end
    end
    return out
end

------------------------------------------------------------------
-- Spell links. An ability only becomes a clickable link when the
-- client itself confirms that the spell ID has the expected name,
-- so a wrong ID can never show the wrong tooltip.
------------------------------------------------------------------
local FALLBACK_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"

function WM:ResolveSpell(ab)
    if ab.checked then return ab.spell end
    ab.checked = true
    local ids = ab.ids
    if not ids and ab.id then ids = { ab.id } end
    if not ids or not GetSpellInfo then return nil end
    -- ab.spellName: the spell's real in-game name when it differs from the
    -- name shown in the guide (e.g. Malygos' "Deep Breath" is the spell
    -- "Surge of Power", Blizzard's own typo "Diminsh Power").
    local want = lower(ab.spellName or ab.name)
    for _, id in ipairs(ids) do
        local n, _, icon = GetSpellInfo(id)
        if n and lower(n) == want then
            ab.spell = id
            ab.icon = icon
            ab.clientName = n
            return id
        end
    end
    return nil
end

function WM:SpellLink(ab)
    local id = self:ResolveSpell(ab)
    if not id then return nil end
    -- chat links carry the spell's real in-game name so the server accepts them
    return "|cff71d5ff|Hspell:" .. id .. "|h[" .. (ab.clientName or ab.name) .. "]|h|r"
end

local function EscapePattern(s)
    return (string.gsub(s, "([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1"))
end

-- Turns the FIRST mention of each of this boss's abilities/buffs/debuffs within
-- a line of prose into its clickable spell link, colored to match the separate
-- Boss Abilities / Buffs & Debuffs lists (plain = blue, buff = green, debuff =
-- red) - so "avoid Locust Swarm" in a Strategy bullet becomes clickable too, not
-- just the standalone ability entry below it. Matches on whole-word boundaries
-- only, and only when the spell ID is confirmed (same rule as everywhere else:
-- never link, or mislink, a name this client can't verify).
-- Splits a line of prose into an ordered list of tokens: { text = "word" } for
-- plain text, or { text = "Ability Name", ability = <the boss's ability table> }
-- for a whole-word match of one of this boss's abilities/buffs/debuffs. Used to
-- render the line word-by-word so each ability mention can be a REAL clickable
-- button with a real hover tooltip - the same widgets as the Boss Abilities /
-- Buffs & Debuffs lists - positioned exactly where it's written in the sentence.
-- Only ever matches a name whose spell ID this client has confirmed (same safety
-- rule as everywhere else in the addon: never guess, never link the wrong thing).
function WM:TokenizeLine(line, boss)
    local tokens = {}
    if not line or line == "" then return tokens end
    local matches = {}
    if boss and boss.abilities then
        for _, ab in ipairs(boss.abilities) do
            local id = self:ResolveSpell(ab)
            if id then
                local pattern = "%f[%a]" .. EscapePattern(ab.name) .. "%f[%A]"
                local searchFrom = 1
                while true do
                    local s, e = string.find(line, pattern, searchFrom)
                    if not s then break end
                    matches[#matches + 1] = { s = s, e = e, ab = ab }
                    searchFrom = e + 1
                end
            end
        end
    end
    if #matches == 0 then
        for w in string.gmatch(line, "%S+") do tokens[#tokens + 1] = { text = w } end
        return tokens
    end
    table.sort(matches, function(a, b) return a.s < b.s end)
    local clean, lastEnd = {}, 0
    for _, m in ipairs(matches) do
        if m.s > lastEnd then
            clean[#clean + 1] = m
            lastEnd = m.e
        end
    end
    local pos = 1
    for _, m in ipairs(clean) do
        if m.s > pos then
            for w in string.gmatch(string.sub(line, pos, m.s - 1), "%S+") do
                tokens[#tokens + 1] = { text = w }
            end
        end
        tokens[#tokens + 1] = { text = string.sub(line, m.s, m.e), ability = m.ab }
        pos = m.e + 1
    end
    if pos <= string.len(line) then
        for w in string.gmatch(string.sub(line, pos), "%S+") do
            tokens[#tokens + 1] = { text = w }
        end
    end
    return tokens
end

-- The icon next to an ability row: the real spell icon once resolved, a
-- generic question-mark icon otherwise (never a wrong or made-up icon).
function WM:GetSpellIcon(ab)
    self:ResolveSpell(ab)
    return ab.icon or FALLBACK_ICON
end

-- Counts how many abilities the client could link (for /wm checklinks)
function WM:CheckLinks()
    local total, linked, missing = 0, 0, {}
    for _, id in ipairs(self.raidOrder) do
        for _, boss in ipairs(self.raids[id].bosses) do
            for _, ab in ipairs(boss.abilities or {}) do
                total = total + 1
                if self:ResolveSpell(ab) then
                    linked = linked + 1
                else
                    missing[#missing + 1] = boss.name .. ": " .. ab.name
                end
            end
        end
    end
    return total, linked, missing
end

------------------------------------------------------------------
-- Plain text version of a boss (used by the Copy view: no colours, no links)
------------------------------------------------------------------
function WM:BuildPlainText(boss)
    local raid = self.raids[boss.raidId]
    local role = self.db.role
    local out = {}
    local function add(s) out[#out + 1] = s end
    local function section(title, lines)
        if not lines or #lines == 0 then return end
        add("")
        add(string.upper(title))
        for _, s in ipairs(lines) do
            if string.sub(s, 1, 3) == "## " then
                add("")
                add(string.sub(s, 4) .. ":")
            else
                add("- " .. s)
            end
        end
    end
    add(boss.name .. " - " .. (raid and raid.name or "") .. " (" .. self:GetSize() .. "-man)")
    if boss.tldr then
        add("")
        add("TL;DR: " .. (self:Expand(boss.tldr) or boss.tldr))
    end
    section("How to start the fight", self:ExpandList(boss.start))
    section("Strategy", self:ExpandList(boss.general))
    if role == "ALL" or role == "TANK" then section("Tanks", self:ExpandList(boss.tank)) end
    if role == "ALL" or role == "HEAL" then section("Healers", self:ExpandList(boss.heal)) end
    if role == "ALL" or role == "DPS" then section("DPS", self:ExpandList(boss.dps)) end
    section("Hard mode / Heroic", self:ExpandList(boss.hard))
    if boss.abilities and #boss.abilities > 0 then
        local plain, statuses = {}, {}
        for _, ab in ipairs(boss.abilities) do
            if ab.kind == "buff" or ab.kind == "debuff" then
                statuses[#statuses + 1] = ab
            else
                plain[#plain + 1] = ab
            end
        end
        if #plain > 0 then
            add("")
            add("BOSS ABILITIES")
            for _, ab in ipairs(plain) do
                add("- " .. ab.name .. ": " .. (self:Expand(ab.desc) or ""))
            end
        end
        if #statuses > 0 then
            add("")
            add("BUFFS & DEBUFFS")
            for _, ab in ipairs(statuses) do
                add("- " .. ab.name .. " (" .. string.upper(ab.kind) .. "): " .. (self:Expand(ab.desc) or ""))
            end
        end
    end
    return table.concat(out, "\n")
end

------------------------------------------------------------------
-- Boss-targeted announcement: a chat line (with a clickable link to open
-- the full guide) posted when you target a boss. Replaces the old popup.
------------------------------------------------------------------

-- The announcement shows only the TL;DR (in the selected 10/25-man version)
function WM:GetAnnounceText(boss)
    return self:Expand(boss.tldr) or boss.tldr or ""
end

function WM:AnnounceBoss(boss)
    local text = self:GetAnnounceText(boss)
    local msg = "|cfffc7a2bWrath Mentor:|r |cffffd100" .. boss.name .. "|r - " .. text .. "  " .. self:BossLink(boss)
    DEFAULT_CHAT_FRAME:AddMessage(msg)
end

-- Clicking a Wrath Mentor chat link opens that boss's guide - a plain click,
-- no modifier needed. Hooked at every entry point WoW might route a chat
-- hyperlink click through (SetItemRef, ChatFrame_OnHyperlinkShow, and
-- ChatEdit_InsertLink, which is what a shift-click normally goes through
-- instead of SetItemRef) so it opens the guide no matter which path this
-- client actually takes for a given click. Every link type other than our
-- own "addon:WrathMentor:" prefix is ignored and behaves exactly as it
-- always did - including still inserting into your open chat box on
-- shift-click, same as any other link.
local function HandleWrathMentorLink(link)
    local boss = WM:BossFromLink(link)
    if boss then WM:ShowMain(boss) end
end

if hooksecurefunc then
    if ChatFrame_OnHyperlinkShow then
        hooksecurefunc("ChatFrame_OnHyperlinkShow", function(chatFrame, link, text, button)
            HandleWrathMentorLink(link)
        end)
    end
    if ChatEdit_InsertLink then
        hooksecurefunc("ChatEdit_InsertLink", function(link)
            HandleWrathMentorLink(link)
        end)
    end
    hooksecurefunc("SetItemRef", function(link, text, button, chatFrame)
        HandleWrathMentorLink(link)
    end)
end

------------------------------------------------------------------
-- Announce-once-per-fight tracking and the boss-target event handler
------------------------------------------------------------------
WM.combatShown = {}

function WM:InCombat()
    return self.inCombat or (UnitAffectingCombat("player") and true or false)
end

function WM:OnEnterCombat()
    self.inCombat = true
    self.combatShown = {}
end

function WM:OnLeaveCombat()
    self.inCombat = false
    self.combatShown = {}
end

-- True when the current instance qualifies for an announcement under the
-- player's settings (announcements on, and raid-only if that's enabled).
function WM:AnnounceAllowed()
    if not self.db.announce then return false end
    local inInstance, instanceType = IsInInstance()
    if not inInstance then return false end
    if self.db.announceRaidOnly and instanceType ~= "raid" then return false end
    return true
end

function WM:OnTarget()
    if not self.db then return end
    -- Keep the persistent 3D model preview live if the window is open,
    -- independent of the chat-announcement settings below.
    if self.ui and self.ui.main and self.ui.main:IsShown() then
        self:RefreshModel()
    end
    if not self:AnnounceAllowed() then return end
    local boss = self:FindBossByUnit("target")
    if not boss then return end
    local key = self:BossKey(boss)
    if self.combatShown[key] then return end
    self.combatShown[key] = true
    self:AnnounceBoss(boss)
end

------------------------------------------------------------------
-- Sending to chat (throttled: one line every 0.6s)
------------------------------------------------------------------
local queue, acc = {}, 0
local qf = CreateFrame("Frame")
qf:Hide()
qf:SetScript("OnUpdate", function(self, elapsed)
    acc = acc + elapsed
    if acc >= 0.6 then
        acc = 0
        local item = table.remove(queue, 1)
        if item then SendChatMessage(item.text, item.chan) end
        if #queue == 0 then self:Hide() end
    end
end)

local function SplitMessage(text, maxlen)
    local parts = {}
    while string.len(text) > maxlen do
        local cut = maxlen
        while cut > 1 and string.sub(text, cut, cut) ~= " " do cut = cut - 1 end
        if cut <= 1 then cut = maxlen end
        parts[#parts + 1] = string.sub(text, 1, cut)
        text = string.sub(text, cut + 1)
    end
    if text ~= "" then parts[#parts + 1] = text end
    return parts
end

local function StripColors(s)
    s = string.gsub(s, "|c%x%x%x%x%x%x%x%x", "")
    s = string.gsub(s, "|r", "")
    return s
end

-- Works out which channel Send() should use when none was explicitly given.
-- If the player currently has a chat edit box open (pressed Enter, or a
-- channel-specific key), sends to whatever channel THAT box is set to - same
-- as if they'd typed the message themselves. Only trusted for simple channel
-- types that need no extra argument; "CHANNEL" (custom channels) and
-- "WHISPER" fall through to the old raid/party heuristic instead, since those
-- need a channel number/target name this isn't set up to supply safely.
-- Pulled out as its own function so it's directly testable without needing
-- to drive the send queue's timing.
local SIMPLE_CHAT_TYPES = {
    SAY = true, YELL = true, PARTY = true, RAID = true,
    RAID_WARNING = true, GUILD = true, OFFICER = true, BATTLEGROUND = true,
}
function WM:ResolveSendChannel(channel)
    if channel then return channel end
    if ChatEdit_GetActiveWindow then
        local eb = ChatEdit_GetActiveWindow()
        if eb and eb:IsShown() then
            local ok, chatType = pcall(function() return eb:GetAttribute("chatType") end)
            if ok and chatType and SIMPLE_CHAT_TYPES[chatType] then
                return chatType
            end
        end
    end
    if GetNumRaidMembers() > 0 then
        return "RAID"
    elseif GetNumPartyMembers() > 0 then
        return "PARTY"
    end
    return nil
end

-- Builds the lines "Send to chat" posts for this boss, for the given content
-- mode (strategy | hard | tldr; defaults to the Settings choice). Shared by
-- Send() and the "Test send to chat" preview so both always match.
function WM:BuildSendLines(boss, mode)
    -- What gets sent is configurable in Settings ("Send to chat sends"):
    -- Strategy (default, plus the abilities/buffs it references), Hard Mode
    -- (same, but the hard mode section instead), or just the TL;DR line for a
    -- quick one-liner. TL;DR never includes the ability/buff list, to keep it
    -- short - the other two do.
    mode = mode or self.db.sendContent or "strategy"
    local lines = {}

    if mode == "tldr" then
        lines[#lines + 1] = "[Mentor] " .. boss.name .. " (" .. self:GetSize() .. "-man) - TL;DR"
        lines[#lines + 1] = self:Expand(boss.tldr) or boss.tldr or ""
    else
        local heading, content
        if mode == "hard" then
            heading, content = "Hard Mode", boss.hard
        else
            heading, content = "Strategy", boss.general
        end
        lines[#lines + 1] = "[Mentor] " .. boss.name .. " (" .. self:GetSize() .. "-man) - " .. heading
        for _, s in ipairs(self:ExpandList(content)) do
            if string.sub(s, 1, 3) == "## " then
                lines[#lines + 1] = "-- " .. string.sub(s, 4) .. " --"
            else
                lines[#lines + 1] = "- " .. s
            end
        end

        -- Ability/buff/debuff links, packed so a link is never cut in half. Real
        -- spell links (when resolved) are clickable for everyone who sees them,
        -- not just you - that's a normal feature of any spell hyperlink in chat.
        local function packLinks(packHeading, list)
            if #list == 0 then return end
            local cur = packHeading
            for _, ab in ipairs(list) do
                local piece = self:SpellLink(ab) or ("[" .. ab.name .. "]")
                if ab.kind then piece = piece .. (ab.kind == "buff" and "(B)" or "(D)") end
                if string.len(cur) + string.len(piece) + 1 > 240 then
                    lines[#lines + 1] = cur
                    cur = ""
                end
                cur = cur .. " " .. piece
            end
            if cur ~= "" and cur ~= packHeading then lines[#lines + 1] = cur end
        end

        local plainAbs, statusAbs = {}, {}
        for _, ab in ipairs(boss.abilities or {}) do
            if ab.kind == "buff" or ab.kind == "debuff" then
                statusAbs[#statusAbs + 1] = ab
            else
                plainAbs[#plainAbs + 1] = ab
            end
        end
        packLinks("Abilities:", plainAbs)
        packLinks("Buffs/Debuffs:", statusAbs)
    end
    return lines
end

function WM:Send(boss, channel)
    if not boss then
        self:Print("No boss selected.")
        return
    end
    channel = self:ResolveSendChannel(channel)
    local lines = self:BuildSendLines(boss)

    if not channel then
        -- Solo: just print it locally
        for _, l in ipairs(lines) do self:Print(l) end
        return
    end
    for _, l in ipairs(lines) do
        for _, part in ipairs(SplitMessage(StripColors(l), 240)) do
            queue[#queue + 1] = { text = part, chan = channel }
        end
    end
    qf:Show()
end

-- "Test send to chat": shows in YOUR chat frame only (nothing is sent to anyone)
-- exactly the lines Send to chat would post, cut into the same chat-sized
-- pieces, for the content currently chosen in Settings.
local SEND_MODE_NAMES = { strategy = "Strategy", hard = "Hard Mode", tldr = "TL;DR" }
function WM:PreviewSend(boss)
    if not boss then
        self:Print("No boss selected.")
        return
    end
    local mode = self.db.sendContent or "strategy"
    local channel = self:ResolveSendChannel(nil)
    local where = channel and (string.lower(channel) .. " chat") or "your own chat frame (you are not in a group)"
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ccffWrath Mentor test|r |cff9d9d9d- only you can see this. \"" ..
        (SEND_MODE_NAMES[mode] or mode) .. "\" for " .. boss.name .. " would be sent to " .. where .. ":|r")
    for _, l in ipairs(self:BuildSendLines(boss, mode)) do
        for _, part in ipairs(SplitMessage(StripColors(l), 240)) do
            DEFAULT_CHAT_FRAME:AddMessage("|cffaaaaaa>|r " .. part)
        end
    end
    if mode == "hard" and #(self:ExpandList(boss.hard) or {}) == 0 then
        DEFAULT_CHAT_FRAME:AddMessage("|cff9d9d9d(" .. boss.name .. " has no hard mode text, so only the heading and abilities would be sent.)|r")
    end
end

------------------------------------------------------------------
-- Slash commands
------------------------------------------------------------------
function WM:HandleSlash(msg)
    msg = msg or ""
    local cmd, rest = string.match(msg, "^(%S*)%s*(.-)$")
    cmd = lower(cmd)
    rest = rest or ""

    if cmd == "" then
        self:ToggleMain()
    elseif cmd == "help" or cmd == "?" then
        self:Print("Commands:")
        self:Print("/wm - open or close the window")
        self:Print("/wm <boss name> - open a boss (partial names work, e.g. /wm lich)")
        self:Print("/wm role all||tank||heal||dps - set your role filter")
        self:Print("/wm size 10||25 - choose the raid size the tactics are written for")
        self:Print("/wm notes - open or close the personal notes box")
        self:Print("/wm announce - toggle the chat announcement when you target a boss (once per fight)")
        self:Print("/wm models - toggle the 3D Model view on or off")
        self:Print("/wm minimap - toggle the minimap button on or off")
        self:Print("/wm modeltest - print a step-by-step diagnostic for the 3D model preview")
        self:Print("/wm loot - open or close the loot table of the selected boss")
        self:Print("/wm config - open or close the settings page")
        self:Print("/wm send [raid||party||say] - send the selected boss's STRATEGY section to chat")
        self:Print("/wm checklinks - report how many ability links this client can resolve")
        self:Print("/wm reset - reset window positions")
    elseif cmd == "announce" then
        self.db.announce = not self.db.announce
        self:Print("Chat announcement " .. (self.db.announce and "enabled." or "disabled."))
        self:RefreshOptions()
    elseif cmd == "models" then
        self.db.modelsEnabled = not self.db.modelsEnabled
        self:Print("3D Model view " .. (self.db.modelsEnabled and "enabled." or "disabled."))
        self:ApplySettings()
    elseif cmd == "modeltest" then
        self:DebugModel()
    elseif cmd == "minimap" then
        self.db.minimap.hide = not self.db.minimap.hide
        self:Print("Minimap button " .. (self.db.minimap.hide and "hidden. Use /wm minimap to bring it back." or "shown."))
        self:ApplySettings()
    elseif cmd == "loot" then
        if not self.ui.main or not self.ui.main:IsShown() then self:ShowMain() end
        self:ToggleLoot()
    elseif cmd == "config" or cmd == "options" or cmd == "settings" then
        self:OpenOptions()
    elseif cmd == "role" then
        local r = string.upper(rest)
        if r == "HEALER" then r = "HEAL" end
        if r == "ALL" or r == "TANK" or r == "HEAL" or r == "DPS" then
            self:SetRole(r)
            self:Print("Role filter: " .. ROLE_NAME[r])
        else
            self:Print("Use: /wm role all||tank||heal||dps")
        end
    elseif cmd == "size" then
        local n = tonumber(rest)
        if n == 10 or n == 25 then
            self:SetSize(n)
            self:Print("Tactics now written for " .. n .. "-man.")
        else
            self:Print("Use: /wm size 10  or  /wm size 25")
        end
    elseif cmd == "notes" then
        if not self.ui.main or not self.ui.main:IsShown() then self:ShowMain() end
        self:ToggleNotes()
    elseif cmd == "checklinks" then
        local total, linked, missing = self:CheckLinks()
        self:Print(linked .. " of " .. total .. " abilities resolved to clickable spell links on this client.")
        if #missing > 0 then
            self:Print("Shown as plain text (no matching spell ID): " .. #missing)
            for i = 1, math.min(#missing, 8) do self:Print("  " .. missing[i]) end
        end
    elseif cmd == "send" then
        local chan = string.upper(rest)
        if chan == "" then chan = nil end
        if chan and chan ~= "RAID" and chan ~= "PARTY" and chan ~= "SAY" then
            self:Print("Channel must be raid, party or say.")
            return
        end
        local boss = self.selected or self:FindBossByUnit("target")
        self:Send(boss, chan)
    elseif cmd == "reset" then
        self.db.mainPos = nil
        self.db.mainWidth = DEFAULTS.mainWidth
        self.db.mainHeight = DEFAULTS.mainHeight
        self:ResetPositions()
        self:Print("Positions and window size reset.")
    else
        local boss = self:FindBoss(msg)
        if boss then
            self:ShowMain(boss)
        else
            self:Print("No boss found for '" .. msg .. "'. Try /wm help.")
        end
    end
end

SLASH_WRATHMENTOR1 = "/wm"
SLASH_WRATHMENTOR2 = "/wrathmentor"
SLASH_WRATHMENTOR3 = "/mentor"
SlashCmdList["WRATHMENTOR"] = function(msg) WM:HandleSlash(msg) end

------------------------------------------------------------------
-- Events
------------------------------------------------------------------
local ev = CreateFrame("Frame")
ev:RegisterEvent("ADDON_LOADED")
ev:RegisterEvent("PLAYER_TARGET_CHANGED")
ev:RegisterEvent("PLAYER_REGEN_ENABLED")
ev:RegisterEvent("PLAYER_REGEN_DISABLED")
ev:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == WM.folder then
            WM:Init()
            WM:SetupUI()
        end
    elseif event == "PLAYER_TARGET_CHANGED" then
        WM:OnTarget()
    elseif event == "PLAYER_REGEN_DISABLED" then
        WM:OnEnterCombat()
    elseif event == "PLAYER_REGEN_ENABLED" then
        WM:OnLeaveCombat()
    end
end)
