-- Wrath Mentor - UI (v2)
local WM = WrathMentor

local ROW_H = 18
local LIST_W = 196
local DETAIL_W = 440

local ui = { rows = {}, roleButtons = {}, sizeButtons = {}, fsPool = {}, abPool = {}, buffPool = {}, wordPool = {}, wordBtnPool = {}, optChecks = {} }
WM.ui = ui

local ROLES = {
    { "ALL", "All", 48 },
    { "TANK", "Tank", 52 },
    { "HEAL", "Healer", 60 },
    { "DPS", "DPS", 48 },
}

local C = {
    title = "|cffffd100",
    tldr = "|cff33ff99",
    start = "|cffffa040",
    strat = "|cffffd100",
    tank = "|cff5aa7ff",
    heal = "|cff4cff4c",
    dps = "|cffff6a4c",
    abil = "|cffd7a8ff",
    buffdebuff = "|cff8fd8ff",
    buff = "|cff6effa0",
    debuff = "|cffff6b6b",
    hard = "|cffff7070",
    grey = "|cff9d9d9d",
    white = "|cffffffff",
    sub = "|cff8fd8ff",
}

------------------------------------------------------------------
-- Flat dark style (shared look with Raid Loot Tracker)
------------------------------------------------------------------
local S = {
    bg      = { 0.05, 0.05, 0.07, 0.96 },
    panel   = { 0.08, 0.08, 0.11, 1 },
    band    = { 0.10, 0.10, 0.14, 1 },
    border  = { 0.20, 0.20, 0.26, 1 },
    button  = { 0.12, 0.12, 0.16, 1 },
    active  = { 0.16, 0.32, 0.42, 1 },
    accent  = { 0.31, 0.76, 0.97, 1 },
    danger  = { 0.90, 0.30, 0.30, 1 },
}

local FLAT_BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1, insets = { left = 1, right = 1, top = 1, bottom = 1 },
}

local function Flat(f, bg, border)
    f:SetBackdrop(FLAT_BACKDROP)
    f:SetBackdropColor(unpack(bg or S.bg))
    f:SetBackdropBorderColor(unpack(border or S.border))
end

-- Flat accent highlight used on every hoverable row / inline link.
local function FlatHighlight(btn, alpha)
    local hl = btn:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints(btn)
    hl:SetTexture(S.accent[1], S.accent[2], S.accent[3], alpha or 0.15)
    return hl
end

-- Flat button with the same API as UIPanelButtonTemplate (SetText, Enable,
-- Disable, OnClick...). A DISABLED button is drawn as the "selected" choice
-- (role, raid size, send-to-chat content), which is how those buttons
-- already worked - only the look changes.
local function FlatButton(name, parent, w, h, danger)
    local b = CreateFrame("Button", name, parent)
    b:SetWidth(w)
    b:SetHeight(h or 22)
    Flat(b, S.button)
    local fs = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fs:SetPoint("CENTER", b, "CENTER", 0, 0)
    b:SetFontString(fs)
    b._hover = danger and S.danger or S.accent

    local function Paint(self)
        if self._disabled then
            self:SetBackdropColor(unpack(S.active))
            self:SetBackdropBorderColor(unpack(S.accent))
            self:GetFontString():SetTextColor(1, 1, 1)
        else
            self:SetBackdropColor(unpack(S.button))
            if self._over then
                self:SetBackdropBorderColor(unpack(self._hover))
            else
                self:SetBackdropBorderColor(unpack(S.border))
            end
            self:GetFontString():SetTextColor(0.92, 0.92, 0.95)
        end
    end
    b._paint = Paint

    local origEnable, origDisable = b.Enable, b.Disable
    b.Enable = function(self) self._disabled = false; origEnable(self); Paint(self) end
    b.Disable = function(self) self._disabled = true; origDisable(self); Paint(self) end

    b:SetScript("OnEnter", function(self) self._over = true; Paint(self) end)
    b:SetScript("OnLeave", function(self) self._over = false; Paint(self); GameTooltip:Hide() end)
    b:SetScript("OnMouseDown", function(self) if not self._disabled then self:GetFontString():SetPoint("CENTER", self, "CENTER", 1, -1) end end)
    b:SetScript("OnMouseUp", function(self) self:GetFontString():SetPoint("CENTER", self, "CENTER", 0, 0) end)
    Paint(b)
    return b
end

-- Buttons that also show a tooltip keep the hover border: wraps OnEnter/OnLeave.
local function AddTooltip(b, fn)
    b:SetScript("OnEnter", function(self) self._over = true; self._paint(self); fn(self) end)
    b:SetScript("OnLeave", function(self) self._over = false; self._paint(self); GameTooltip:Hide() end)
end

-- Title bar: dark band + thin accent line + icon + title + "by" line + flat X.
local function TitleBar(f, titleText, subText, onClose)
    local bar = CreateFrame("Frame", nil, f)
    bar:SetPoint("TOPLEFT", f, "TOPLEFT", 1, -1)
    bar:SetPoint("TOPRIGHT", f, "TOPRIGHT", -1, -1)
    bar:SetHeight(30)
    local bg = bar:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(bar)
    bg:SetTexture(0.09, 0.09, 0.12, 1)
    local line = bar:CreateTexture(nil, "BORDER")
    line:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", 0, 0)
    line:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, 0)
    line:SetHeight(1)
    line:SetTexture(S.accent[1], S.accent[2], S.accent[3], 0.6)

    local icon = bar:CreateTexture(nil, "ARTWORK")
    icon:SetWidth(24)
    icon:SetHeight(24)
    icon:SetPoint("LEFT", bar, "LEFT", 6, 0)
    icon:SetTexture(WM.media .. "minimap")

    local title = bar:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("LEFT", icon, "RIGHT", 8, 0)
    title:SetTextColor(1, 1, 1)
    title:SetText(titleText)

    local sub = bar:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    sub:SetPoint("LEFT", title, "RIGHT", 8, -1)
    sub:SetText(subText or "")

    local close = FlatButton(nil, bar, 22, 20, true)
    close:SetPoint("RIGHT", bar, "RIGHT", -6, 0)
    close:SetText("X")
    close:SetScript("OnClick", onClose)
    bar.close = close
    return bar, bg
end

-- Dotted bottom-right resize grip.
local function ResizeGrip(f, onDone)
    local grip = CreateFrame("Button", nil, f)
    grip:SetWidth(16)
    grip:SetHeight(16)
    grip:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2, 2)
    grip:SetFrameLevel(f:GetFrameLevel() + 20)
    grip.dots = {}
    for i, p in ipairs({ { 0, 0 }, { 5, 0 }, { 10, 0 }, { 5, 5 }, { 10, 5 }, { 10, 10 } }) do
        local d = grip:CreateTexture(nil, "OVERLAY")
        d:SetWidth(3)
        d:SetHeight(3)
        d:SetPoint("BOTTOMLEFT", grip, "BOTTOMLEFT", p[1] + 1, p[2] + 1)
        d:SetTexture(0.55, 0.55, 0.6, 0.9)
        grip.dots[i] = d
    end
    local function Tint(r, g, b) for _, d in ipairs(grip.dots) do d:SetTexture(r, g, b, 0.9) end end
    grip:SetScript("OnEnter", function(self)
        Tint(S.accent[1], S.accent[2], S.accent[3])
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
        GameTooltip:AddLine("Drag to resize the window")
        GameTooltip:Show()
    end)
    grip:SetScript("OnLeave", function() Tint(0.55, 0.55, 0.6); GameTooltip:Hide() end)
    grip:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then f:StartSizing("BOTTOMRIGHT") end
    end)
    grip:SetScript("OnMouseUp", function()
        f:StopMovingOrSizing()
        if onDone then onDone() end
    end)
    return grip
end

-- Flat panel drawn behind a content area (list, text, notes box...). Made of
-- two textures on the parent itself (1px border + fill) rather than a child
-- frame, so it can never end up drawn over the parent's own text (like the
-- big boss-name heading). Returns the outer texture: anchor/size that one.
-- With no color given, the inside is left see-through, so it shows exactly
-- the window's own background and the box only adds a thin outline.
local function Panel(parent, color)
    local edge = parent:CreateTexture(nil, "BACKGROUND")
    edge:SetTexture(S.border[1], S.border[2], S.border[3], 1)
    local fill = parent:CreateTexture(nil, "BORDER")
    if color then
        fill:SetTexture(color[1], color[2], color[3], color[4] or 1)
    else
        -- same colour as the window backdrop, fully opaque over the 1px edge
        fill:SetTexture(S.bg[1], S.bg[2], S.bg[3], 1)
    end
    fill:SetPoint("TOPLEFT", edge, "TOPLEFT", 1, -1)
    fill:SetPoint("BOTTOMRIGHT", edge, "BOTTOMRIGHT", -1, 1)
    return edge
end

------------------------------------------------------------------
-- Helpers
------------------------------------------------------------------
local function SavePos(frame, key)
    local point, _, relPoint, x, y = frame:GetPoint()
    WM.db[key] = { point, relPoint, x, y }
end

local function RestorePos(frame, key, point, relPoint, x, y)
    frame:ClearAllPoints()
    local p = WM.db and WM.db[key]
    if p then
        frame:SetPoint(p[1], UIParent, p[2], p[3], p[4])
    else
        frame:SetPoint(point, UIParent, relPoint, x, y)
    end
end

local function EnableWheel(sf)
    sf:EnableMouseWheel(true)
    sf:SetScript("OnMouseWheel", function(self, delta)
        local cur = self:GetVerticalScroll()
        local max = self:GetVerticalScrollRange()
        local new = cur - delta * 36
        if new < 0 then new = 0 end
        if new > max then new = max end
        self:SetVerticalScroll(new)
    end)
end

------------------------------------------------------------------
-- List rows
------------------------------------------------------------------
local function RowClick(self)
    local d = self.data
    if not d then return end
    if d.raid then
        WM.collapsed[d.raid.id] = not WM.collapsed[d.raid.id]
        WM:RefreshList()
    else
        WM:SelectBoss(d.boss)
    end
end

local function CreateRow(i)
    local btn = CreateFrame("Button", nil, ui.listChild)
    btn:SetWidth(LIST_W)
    btn:SetHeight(ROW_H)
    btn:SetPoint("TOPLEFT", ui.listChild, "TOPLEFT", 0, -(i - 1) * ROW_H)
    FlatHighlight(btn, 0.12)
    btn.band = btn:CreateTexture(nil, "BACKGROUND")
    btn.band:SetAllPoints(btn)
    btn.band:SetTexture(S.band[1], S.band[2], S.band[3], 1)
    btn.band:Hide()
    btn.sel = btn:CreateTexture(nil, "BACKGROUND")
    btn.sel:SetAllPoints(btn)
    btn.sel:SetTexture(S.accent[1], S.accent[2], S.accent[3], 0.18)
    btn.sel:Hide()
    btn.selBar = btn:CreateTexture(nil, "ARTWORK")
    btn.selBar:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)
    btn.selBar:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 0, 0)
    btn.selBar:SetWidth(2)
    btn.selBar:SetTexture(S.accent[1], S.accent[2], S.accent[3], 1)
    btn.selBar:Hide()
    btn.text = btn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    btn.text:SetJustifyH("LEFT")
    btn.text:SetWidth(LIST_W - 22)
    btn:SetScript("OnClick", RowClick)
    return btn
end

function WM:RefreshList()
    if not ui.main then return end
    local rows = {}
    for _, id in ipairs(self.raidOrder) do
        local raid = self.raids[id]
        rows[#rows + 1] = { raid = raid }
        if not self.collapsed[id] then
            for _, boss in ipairs(raid.bosses) do
                rows[#rows + 1] = { boss = boss }
            end
        end
    end
    for i, data in ipairs(rows) do
        local btn = ui.rows[i]
        if not btn then
            btn = CreateRow(i)
            ui.rows[i] = btn
        end
        btn.data = data
        btn.text:ClearAllPoints()
        if data.raid then
            local mark = self.collapsed[data.raid.id] and "+ " or "- "
            btn.text:SetPoint("LEFT", btn, "LEFT", 2, 0)
            btn.text:SetText(mark .. data.raid.name)
            btn.text:SetTextColor(1, 0.82, 0)
            btn.sel:Hide()
            btn.selBar:Hide()
            btn.band:Hide()
        else
            btn.text:SetPoint("LEFT", btn, "LEFT", 16, 0)
            btn.text:SetText(data.boss.name)
            if self.db.notes[self:BossKey(data.boss)] then
                btn.text:SetTextColor(0.55, 0.85, 1)   -- bosses with personal notes are tinted blue
            else
                btn.text:SetTextColor(0.9, 0.9, 0.9)
            end
            btn.band:Hide()
            if data.boss == self.selected then
                btn.sel:Show(); btn.selBar:Show()
            else
                btn.sel:Hide(); btn.selBar:Hide()
            end
        end
        btn:Show()
    end
    for i = #rows + 1, #ui.rows do
        ui.rows[i]:Hide()
    end
    ui.listChild:SetHeight(math.max(#rows * ROW_H, 10))
end

------------------------------------------------------------------
-- Detail pane (block layout: text blocks + clickable ability rows)
------------------------------------------------------------------
local function GetFS(i)
    local fs = ui.fsPool[i]
    if not fs then
        fs = ui.detailChild:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        fs:SetJustifyH("LEFT")
        fs:SetJustifyV("TOP")
        ui.fsPool[i] = fs
    end
    return fs
end

local function AbilityEnter(self)
    local ab = self.ab
    if not ab then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    local id = WM:ResolveSpell(ab)
    if id then
        GameTooltip:SetHyperlink("spell:" .. id)
    else
        GameTooltip:AddLine(ab.name, 1, 1, 1)
    end
    GameTooltip:Show()
end

local function AbilityLeave()
    GameTooltip:Hide()
end

local function AbilityClick(self, button)
    local ab = self.ab
    if not ab then return end
    local link = WM:SpellLink(ab)
    if not link then return end
    if IsModifiedClick and IsModifiedClick("CHATLINK") and ChatEdit_InsertLink and ChatEdit_InsertLink(link) then
        return
    end
    if SetItemRef then SetItemRef("spell:" .. ab.spell, link, button or "LeftButton") end
end

-- Word pool: a plain FontString for one non-ability word in a flowed line.
local function GetWordFS(i)
    local fs = ui.wordPool[i]
    if not fs then
        fs = ui.detailChild:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        fs:SetJustifyH("LEFT")
        ui.wordPool[i] = fs
    end
    return fs
end

-- Word-button pool: a small clickable/hoverable button sized to fit exactly one
-- ability/buff/debuff name, used in place of a plain word wherever one is
-- mentioned in flowed prose. Uses the SAME AbilityEnter/Leave/Click handlers as
-- the Boss Abilities / Buffs & Debuffs list rows, so it behaves identically.
local function GetWordBtn(i)
    local row = ui.wordBtnPool[i]
    if not row then
        local btn = CreateFrame("Button", nil, ui.detailChild)
        btn:SetHeight(14)
        FlatHighlight(btn, 0.18)
        local txt = btn:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        txt:SetPoint("LEFT", btn, "LEFT", 0, 0)
        txt:SetJustifyH("LEFT")
        btn.text = txt
        btn:SetScript("OnEnter", AbilityEnter)
        btn:SetScript("OnLeave", AbilityLeave)
        btn:SetScript("OnClick", AbilityClick)
        row = { btn = btn }
        ui.wordBtnPool[i] = row
    end
    return row
end

local function CreateAbRow(parent)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetHeight(16)
    btn:SetWidth(DETAIL_W - 8)
    FlatHighlight(btn, 0.12)
    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetWidth(16)
    icon:SetHeight(16)
    icon:SetPoint("LEFT", btn, "LEFT", 0, 0)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)  -- trim the default icon border
    local row = { icon = icon }
    btn.text = btn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    btn.text:SetPoint("LEFT", icon, "RIGHT", 4, 0)
    btn.text:SetJustifyH("LEFT")
    btn:SetScript("OnEnter", AbilityEnter)
    btn:SetScript("OnLeave", AbilityLeave)
    btn:SetScript("OnClick", AbilityClick)
    row.btn = btn
    row.desc = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    row.desc:SetJustifyH("LEFT")
    row.desc:SetJustifyV("TOP")
    return row
end

local function GetAbRow(i)
    local row = ui.abPool[i]
    if not row then
        row = CreateAbRow(ui.detailChild)
        ui.abPool[i] = row
    end
    return row
end

local function GetBuffRow(i)
    local row = ui.buffPool[i]
    if not row then
        row = CreateAbRow(ui.detailChild)
        ui.buffPool[i] = row
    end
    return row
end

function WM:RefreshDetail()
    if not ui.main then return end
    for key, b in pairs(ui.roleButtons) do
        if key == self.db.role then b:Disable() else b:Enable() end
    end
    for key, b in pairs(ui.sizeButtons) do
        if key == self:GetSize() then b:Disable() else b:Enable() end
    end
    local boss = self.selected
    local used, usedAb, usedBuff, usedWord, usedWordBtn = 0, 0, 0, 0, 0
    local y = 0
    local dw = (ui.detailScroll and ui.detailScroll:GetWidth()) or DETAIL_W
    if not dw or dw <= 0 then dw = DETAIL_W end

    local function text(str, font, gap)
        used = used + 1
        local fs = GetFS(used)
        fs:SetFontObject(font or GameFontHighlight)
        fs:ClearAllPoints()
        fs:SetPoint("TOPLEFT", ui.detailChild, "TOPLEFT", 0, -y)
        fs:SetWidth(dw - 8)
        fs:SetText(str)
        fs:Show()
        y = y + fs:GetStringHeight() + (gap or 6)
    end

    -- Renders one ability/buff/debuff row (icon + link + description) from getRow(i)
    local function abilityRow(getRow, i, ab, nameColor)
        local row = getRow(i)
        row.btn.ab = ab
        row.btn:ClearAllPoints()
        row.btn:SetPoint("TOPLEFT", ui.detailChild, "TOPLEFT", 4, -y)
        row.btn:SetWidth(dw - 8)
        row.icon:SetTexture(WM:GetSpellIcon(ab))
        if WM:ResolveSpell(ab) then
            row.btn.text:SetText((nameColor or "|cff71d5ff") .. "[" .. ab.name .. "]|r")
        else
            row.btn.text:SetText(C.white .. ab.name .. "|r")
        end
        row.btn:Show()
        y = y + 18
        row.desc:ClearAllPoints()
        row.desc:SetPoint("TOPLEFT", ui.detailChild, "TOPLEFT", 20, -y)
        row.desc:SetWidth(dw - 28)
        row.desc:SetText(self:Expand(ab.desc) or "")
        row.desc:Show()
        y = y + row.desc:GetStringHeight() + 7
    end

    -- Renders one bullet line word-by-word, wrapping at the available width, so
    -- any ability/buff/debuff mentioned by name becomes a REAL clickable button
    -- (GetWordBtn, same AbilityEnter/Leave/Click as the full lists) positioned
    -- exactly where it's written - not a separate section, not inert colored
    -- text, an actual working hover tooltip and click right in the sentence.
    local WORD_GAP, LINE_H, BULLET_INDENT = 4, 14, 10
    local function measureWidth(str)
        ui.measureFS:SetText(str)
        return ui.measureFS:GetStringWidth() or 0
    end
    local function flowLine(line)
        if string.sub(line, 1, 3) == "## " then
            text(C.sub .. string.sub(line, 4) .. "|r", GameFontNormal, 2)
            return
        end
        local maxW = dw - 8
        local x = BULLET_INDENT

        usedWord = usedWord + 1
        local dashFS = GetWordFS(usedWord)
        dashFS:SetFontObject(GameFontHighlight)
        dashFS:ClearAllPoints()
        dashFS:SetPoint("TOPLEFT", ui.detailChild, "TOPLEFT", 0, -y)
        dashFS:SetText("-")
        dashFS:Show()

        for _, tok in ipairs(WM:TokenizeLine(line, boss)) do
            local w = measureWidth(tok.text)
            if x > BULLET_INDENT and x + w > maxW then
                x = BULLET_INDENT
                y = y + LINE_H
            end
            if tok.ability then
                usedWordBtn = usedWordBtn + 1
                local row = GetWordBtn(usedWordBtn)
                row.btn.ab = tok.ability
                row.btn:ClearAllPoints()
                row.btn:SetPoint("TOPLEFT", ui.detailChild, "TOPLEFT", x, -y)
                row.btn:SetWidth(w + 2)
                local kind = tok.ability.kind
                local color = (kind == "buff" and C.buff) or (kind == "debuff" and C.debuff) or "|cff71d5ff"
                row.btn.text:SetText(color .. tok.text .. "|r")
                row.btn:Show()
            else
                usedWord = usedWord + 1
                local fs = GetWordFS(usedWord)
                fs:SetFontObject(GameFontHighlight)
                fs:ClearAllPoints()
                fs:SetPoint("TOPLEFT", ui.detailChild, "TOPLEFT", x, -y)
                fs:SetText(tok.text)
                fs:Show()
            end
            x = x + w + WORD_GAP
        end
        y = y + LINE_H + 4
    end

    local function section(title, color, lines)
        if not lines or #lines == 0 then return end
        text(color .. title .. "|r", GameFontNormal, 2)
        for _, l in ipairs(lines) do flowLine(l) end
        y = y + 6
    end

    if boss then
        local raid = self.raids[boss.raidId]
        local role = self.db.role
        local roleName = ({ ALL = "All roles", TANK = "Tank", HEAL = "Healer", DPS = "DPS" })[role]

        text(C.title .. boss.name .. "|r  " .. C.grey .. "(" .. (raid and raid.name or "?") .. " - " .. self:GetSize() .. "-man - " .. roleName .. ")|r", GameFontNormalLarge, 8)

        if boss.tldr then
            text(C.tldr .. "TL;DR|r  " .. (self:Expand(boss.tldr) or boss.tldr), GameFontHighlight, 10)
        end
        section("How to start the fight", C.start, self:ExpandList(boss.start))
        section("Strategy", C.strat, self:ExpandList(boss.general))

        if role == "ALL" or role == "TANK" then section("Tanks", C.tank, self:ExpandList(boss.tank)) end
        if role == "ALL" or role == "HEAL" then section("Healers", C.heal, self:ExpandList(boss.heal)) end
        if role == "ALL" or role == "DPS" then section("DPS", C.dps, self:ExpandList(boss.dps)) end

        section("Hard mode / Heroic - full explanation", C.hard, self:ExpandList(boss.hard))

        -- Split abilities into plain attacks/mechanics and status effects (buffs/debuffs).
        -- Shown last, as the full reference list - each one is also already clickable
        -- right where it's mentioned earlier in the text above.
        local plainAbs, statusAbs = {}, {}
        for _, ab in ipairs(boss.abilities or {}) do
            if ab.kind == "buff" or ab.kind == "debuff" then
                statusAbs[#statusAbs + 1] = ab
            else
                plainAbs[#plainAbs + 1] = ab
            end
        end

        if #plainAbs > 0 then
            text(C.abil .. "Boss abilities|r  " .. C.grey .. "(hover for the game tooltip, click to open it, shift-click to link in chat)|r", GameFontNormal, 4)
            for _, ab in ipairs(plainAbs) do
                usedAb = usedAb + 1
                abilityRow(GetAbRow, usedAb, ab)
            end
            y = y + 4
        end

        if #statusAbs > 0 then
            text(C.buffdebuff .. "Buffs & Debuffs|r  " .. C.grey .. "(" .. C.buff .. "green|r = buff, " .. C.debuff .. "red|r = debuff)|r", GameFontNormal, 4)
            for _, ab in ipairs(statusAbs) do
                usedBuff = usedBuff + 1
                local nameColor = (ab.kind == "buff") and C.buff or C.debuff
                abilityRow(GetBuffRow, usedBuff, ab, nameColor)
            end
            y = y + 4
        end

    else
        text("", GameFontHighlight, 0)
    end

    for i = used + 1, #ui.fsPool do ui.fsPool[i]:Hide() end
    for i = usedAb + 1, #ui.abPool do
        ui.abPool[i].btn:Hide()
        ui.abPool[i].desc:Hide()
    end
    for i = usedBuff + 1, #ui.buffPool do
        ui.buffPool[i].btn:Hide()
        ui.buffPool[i].desc:Hide()
    end
    for i = usedWord + 1, #ui.wordPool do ui.wordPool[i]:Hide() end
    for i = usedWordBtn + 1, #ui.wordBtnPool do ui.wordBtnPool[i].btn:Hide() end
    ui.detailChild:SetHeight(y + 12)
    ui.detailScroll:SetVerticalScroll(0)
    self:RefreshBossNameHeading()
    self:RefreshActiveView()
end

------------------------------------------------------------------
-- Copy view: the whole boss text as plain, selectable text.
-- (Normal on-screen text cannot be selected in WoW; an edit box can.)
------------------------------------------------------------------
function WM:RefreshCopy()
    if not ui.copyFrame then return end
    if ui.copyScroll and ui.copyEdit then
        local cw = ui.copyScroll:GetWidth()
        if cw and cw > 0 then
            ui.copyEdit:SetWidth(cw - 6)
            if ui.copyMeasure then ui.copyMeasure:SetWidth(cw - 6) end
        end
    end
    local boss = self.selected
    local text = boss and self:BuildPlainText(boss) or ""
    ui.copyText = text
    ui.copyEdit:SetText(text)
    ui.copyMeasure:SetText(text)
    local h = ui.copyMeasure:GetStringHeight()
    if not h or h < 1 then h = string.len(text) / 60 * 14 end
    ui.copyEdit:SetHeight(math.max(322, h + 24))
    ui.copyScroll:SetVerticalScroll(0)
    ui.copyEdit:SetCursorPosition(0)
end

------------------------------------------------------------------
-- Persistent 3D model preview - a real, live WoW creature model (Model UI
-- widget), not an image. Always visible when enabled in Settings, next to
-- whichever view (detail/copy/position) is open; never behind its own button.
------------------------------------------------------------------
-- Resets rotation/zoom to a sensible default. Called internally every time
-- the preview switches boss/target - there's no user-facing button for this.
function WM:ResetModelView()
    if not ui.model then return end
    ui.model._zoom = 0
    if ui.model.SetPosition then ui.model:SetPosition(0, 0, 0) end
    if ui.model.SetFacing then ui.model:SetFacing(0) end
    if ui.model.SetPortraitZoom then ui.model:SetPortraitZoom(0.35) end
end

-- True when the player's current target IS this boss (by name or alias) -
-- SetUnit("target") then shows the exact, guaranteed-correct live model,
-- no npcId guesswork needed.
function WM:TargetIsBoss(boss)
    if not UnitExists("target") or UnitIsPlayer("target") then return false end
    local name = string.lower(UnitName("target") or "")
    if name == "" then return false end
    if name == string.lower(boss.name) then return true end
    if boss.aliases then
        for _, a in ipairs(boss.aliases) do
            if name == string.lower(a) then return true end
        end
    end
    return false
end

-- Big centered boss-name heading shown above the detail text, next to the model
-- preview. Uses WoW's own default UI font (Friz Quadrata) at a large size,
-- auto-shrinking to fit so long boss names ("Instructor Razuvious") never clip.
function WM:RefreshBossNameHeading()
    if not ui.bossNameHeading then return end
    local boss = self.selected
    if not boss then
        ui.bossNameHeading:SetText("")
        return
    end
    local maxW = ui.bossNameHeading:GetWidth()
    if not maxW or maxW <= 0 then maxW = 300 end
    local size = 102
    pcall(function()
        while size > 42 do
            ui.bossNameHeading:SetFont("Fonts\\FRIZQT__.TTF", size, "OUTLINE")
            ui.bossNameHeading:SetText(boss.name)
            local w = ui.bossNameHeading:GetStringWidth() or 0
            if w <= maxW then break end
            size = size - 6
        end
    end)
    ui.bossNameHeading:SetTextColor(1, 0.82, 0)
    ui.bossNameHeading:SetText(boss.name)
end

-- Prints a step-by-step report of what happens when the addon tries to show
-- the current boss's 3D model, including the exact error text if any call
-- fails - use /wm modeltest in-game to get a precise diagnosis instead of
-- guessing blind.
function WM:DebugModel()
    self:Print("--- 3D model diagnostic ---")
    self:Print("modelsEnabled setting: " .. tostring(self.db.modelsEnabled))
    if not ui.modelPreview then
        self:Print("ui.modelPreview does NOT exist - the preview panel itself failed to create.")
        return
    end
    self:Print("modelPreview panel exists. Shown=" .. tostring(ui.modelPreview:IsShown()))
    if not ui.model then
        self:Print("ui.model does NOT exist - CreateFrame(\"PlayerModel\", ...) failed or never ran.")
        return
    end
    self:Print("Model widget exists (CreateFrame succeeded). Shown=" .. tostring(ui.model:IsShown()))
    local w, h = ui.model:GetWidth(), ui.model:GetHeight()
    self:Print("Model size: " .. tostring(w) .. " x " .. tostring(h))
    local boss = self.selected
    if not boss then
        self:Print("No boss selected.")
        return
    end
    self:Print("Boss: " .. boss.name .. "   npcId=" .. tostring(boss.npcId) .. "   currently targeting this boss=" .. tostring(self:TargetIsBoss(boss)))
    if self:TargetIsBoss(boss) then
        local ok, err = pcall(function() ui.model:SetUnit("target") end)
        self:Print("ui.model:SetUnit(\"target\") -> " .. (ok and "no error" or ("ERROR: " .. tostring(err))))
    elseif boss.npcId then
        local ok, err = pcall(function() ui.model:SetCreature(boss.npcId) end)
        self:Print("ui.model:SetCreature(" .. boss.npcId .. ") -> " .. (ok and "no error" or ("ERROR: " .. tostring(err))))
    else
        self:Print("This boss has no npcId and you're not targeting it - nothing to show, as expected.")
        return
    end
    self:Print("After the call: model Shown=" .. tostring(ui.model:IsShown()) .. "   parent (modelPreview) Shown=" .. tostring(ui.modelPreview:IsShown()))
    self:Print("--- end diagnostic ---")
end

-- Blanks whatever the model widget is currently displaying, in addition to
-- hiding it - a defensive belt-and-braces step so no stale creature/unit can
-- ever linger visible (or reappear) across a boss switch, regardless of how
-- WoW's Model widget internally handles Hide().
local function ClearModel()
    if ui.model then pcall(function() ui.model:SetModel("") end) end
end

-- There is only ONE model widget shared by every boss page. Its loaded 3D
-- geometry is only ever REPLACED (via ClearModel + a fresh SetUnit/SetCreature)
-- when something NEW needs to be shown - never just because you're looking at
-- an unrelated page. ui.modelLoadedBoss tracks which boss's geometry is
-- CURRENTLY loaded into the widget (whether or not it's visible right now),
-- so returning to that same boss's page - even much later, even without
-- re-targeting - re-shows it instantly instead of needing a fresh live target.
-- Placeholder shown in the model's spot while there is nothing to display yet
-- (boss not targeted this session), so the corner is never just empty.
local function SetModelPlaceholder(boss)
    local ph = ui.modelPlaceholder
    if not ph then return end
    if boss then
        ph.text:SetText("Target |cffffd100" .. boss.name .. "|r\nto load the 3D model")
        ph:Show()
    else
        ph:Hide()
    end
end

function WM:RefreshModel()
    if not ui.modelPreview or not ui.model then return end
    if ui.viewMode == "loot" or ui.settingsShown then
        ui.modelPreview:Hide()
        return
    end
    if not self.db.modelsEnabled then
        ClearModel()
        ui.modelPreview:Hide()
        SetModelPlaceholder(nil)
        ui.modelLoadedBoss = nil
        return
    end
    ui.modelPreview:Show()
    local boss = self.selected
    if not boss then
        ui.model:Hide()
        SetModelPlaceholder(nil)
        return
    end

    if self:TargetIsBoss(boss) then
        -- A fresh, guaranteed-correct live match - always re-set, even if this
        -- boss's geometry happens to already be loaded, since "target" may now
        -- refer to a different instance of the same boss (new pull, etc).
        ClearModel()
        ui.model:Show()
        SetModelPlaceholder(nil)
        pcall(function() ui.model:SetUnit("target") end)
        self:ResetModelView()
        ui.modelLoadedBoss = boss
        return
    end

    if ui.modelLoadedBoss == boss then
        -- This boss's geometry is still loaded from earlier this session (you
        -- targeted it before, then navigated away and came back) - just
        -- un-hide it, no need to re-set anything.
        ui.model:Show()
        SetModelPlaceholder(nil)
        return
    end

    -- boss.npcId is intentionally NOT used here. On this client, SetCreature()
    -- does not throw an error even when it fails to actually change what's
    -- displayed - pcall reports "success" regardless, so there's no reliable
    -- way to tell a real update from a silent no-op. Trusting that false
    -- "success" was exactly what caused a stale, unrelated model (e.g. Ignis)
    -- to keep showing on other bosses' pages. Until there's a way to verify
    -- SetCreature actually worked, it's safer not to call it at all than to
    -- risk displaying the wrong creature with no way to detect the mistake.

    -- Nothing to show for this boss right now, and its geometry isn't already
    -- loaded either - just hide (don't wipe the widget, in case some OTHER
    -- boss's geometry is currently loaded and you navigate back to that one).
    ui.model:Hide()
    SetModelPlaceholder(boss)
end

-- Refreshes whichever non-detail view (currently just copy) is open, if any,
-- plus the persistent model preview - safe to call unconditionally after the
-- boss/role/size/target changes.
function WM:RefreshActiveView()
    if ui.viewMode == "copy" then self:RefreshCopy() end
    self:RefreshModel()
end

-- One view is shown at a time in the main content area: "detail" (the
-- formatted guide, the default) or "copy" (plain selectable text). The 3D
-- model preview is separate from this - it's not a "view", it's always
-- there when enabled.
function WM:SetViewMode(mode)
    if not ui.copyFrame then return end
    if mode ~= "copy" and mode ~= "loot" then mode = "detail" end
    ui.viewMode = mode
    ui.copyMode = (mode == "copy")  -- kept for backward compatibility

    ui.detailScroll:Hide()
    ui.copyFrame:Hide()
    if ui.lootFrame then ui.lootFrame:Hide() end
    -- the loot list uses the space of the boss name heading and the 3D model too
    if ui.bossNameHeading then
        if mode == "loot" then ui.bossNameHeading:Hide() else ui.bossNameHeading:Show() end
    end
    self:RefreshModel()
    if ui.lootButton then ui.lootButton:SetText(mode == "loot" and "Tactics" or "Loot") end
    -- "Send to chat" sends tactics, so it is hidden on the loot page
    if ui.sendButton then
        if mode == "loot" then ui.sendButton:Hide() else ui.sendButton:Show() end
    end

    if mode == "loot" then
        ui.lootFrame:Show()
        self:RefreshLoot()
    elseif mode == "copy" then
        ui.copyFrame:Show()
        self:RefreshCopy()
        ui.copyEdit:SetFocus()
        ui.copyEdit:HighlightText()
    else
        ui.detailScroll:Show()
    end

    if ui.copyButton then ui.copyButton:SetText(mode == "copy" and "Back" or "Copy") end
end

function WM:SetCopyMode(on)
    self:SetViewMode(on and "copy" or "detail")
end

function WM:ToggleCopy()
    self:SetViewMode(ui.viewMode == "copy" and "detail" or "copy")
end

function WM:ToggleLoot()
    self:SetViewMode(ui.viewMode == "loot" and "detail" or "loot")
end

------------------------------------------------------------------
-- Selection / role / size
------------------------------------------------------------------
function WM:SelectBoss(boss)
    if ui.notesDirty then self:SaveNotes(true) end
    self.selected = boss
    if self.collapsed[boss.raidId] then self.collapsed[boss.raidId] = false end
    if ui.main then
        self:RefreshList()
        self:RefreshDetail()
        self:LoadNotes()
    end
end

function WM:SetRole(role)
    self.db.role = role
    if ui.main then self:RefreshDetail() end
end

function WM:SetSize(size)
    self.db.size = size
    if ui.main then self:RefreshDetail() end
end

------------------------------------------------------------------
-- Personal notes (side box)
------------------------------------------------------------------
function WM:RefreshNotesButton()
    if not ui.notesButton then return end
    local has = self.selected and self.db.notes[self:BossKey(self.selected)]
    ui.notesButton:SetText(has and "Notes*" or "Notes")
    if ui.main then self:RefreshList() end
end

local function SetNotesStatus(text)
    if ui.notesStatus then ui.notesStatus:SetText(text or "") end
end

function WM:LoadNotes()
    self:RefreshNotesButton()
    if not ui.notes then return end
    local boss = self.selected
    self.notesBoss = boss
    ui.notesTitle:SetText("Notes - " .. (boss and boss.name or ""))
    ui.notesEdit:SetText((boss and self.db.notes[self:BossKey(boss)]) or "")
    ui.notesEdit:SetCursorPosition(0)
    ui.notesDirty = false
    SetNotesStatus("")
end

function WM:SaveNotes(silent)
    if not ui.notes or not self.notesBoss then return end
    local text = ui.notesEdit:GetText() or ""
    local key = self:BossKey(self.notesBoss)
    if string.match(text, "^%s*$") then
        self.db.notes[key] = nil
    else
        self.db.notes[key] = text
    end
    ui.notesDirty = false
    SetNotesStatus("|cff4cff4cSaved|r")
    self:RefreshNotesButton()
    if not silent then self:Print("Notes saved for " .. self.notesBoss.name .. ".") end
end

local function CreateNotes()
    local n = CreateFrame("Frame", "WrathMentorNotes", ui.main)
    ui.notes = n
    n:SetWidth(270)
    n:SetHeight(360)
    n:SetPoint("TOPLEFT", ui.main, "TOPRIGHT", 4, 0)
    Flat(n, S.bg)
    n:SetClampedToScreen(true)
    n:Hide()

    local bar = n:CreateTexture(nil, "BACKGROUND")
    bar:SetPoint("TOPLEFT", n, "TOPLEFT", 1, -1)
    bar:SetPoint("TOPRIGHT", n, "TOPRIGHT", -1, -1)
    bar:SetHeight(30)
    bar:SetTexture(0.09, 0.09, 0.12, 1)
    local barLine = n:CreateTexture(nil, "BORDER")
    barLine:SetPoint("TOPLEFT", n, "TOPLEFT", 1, -31)
    barLine:SetPoint("TOPRIGHT", n, "TOPRIGHT", -1, -31)
    barLine:SetHeight(1)
    barLine:SetTexture(S.accent[1], S.accent[2], S.accent[3], 0.6)

    ui.notesTitle = n:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    ui.notesTitle:SetPoint("TOPLEFT", n, "TOPLEFT", 12, -9)
    ui.notesTitle:SetWidth(240)
    ui.notesTitle:SetJustifyH("LEFT")
    ui.notesTitle:SetTextColor(1, 1, 1)

    local box = Panel(n)
    box:SetPoint("TOPLEFT", n, "TOPLEFT", 12, -42)
    box:SetPoint("BOTTOMRIGHT", n, "BOTTOMRIGHT", -12, 70)

    local scroll = CreateFrame("ScrollFrame", "WrathMentorNotesScroll", n, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", n, "TOPLEFT", 18, -48)
    scroll:SetWidth(210)
    scroll:SetHeight(236)
    EnableWheel(scroll)

    local edit = CreateFrame("EditBox", "WrathMentorNotesEdit", scroll)
    ui.notesEdit = edit
    edit:SetMultiLine(true)
    edit:SetAutoFocus(false)
    edit:SetFontObject(ChatFontNormal)
    edit:SetWidth(206)
    edit:SetHeight(240)
    edit:SetMaxLetters(4000)
    scroll:SetScrollChild(edit)
    edit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    edit:SetScript("OnTextChanged", function(self, userInput)
        if userInput then
            ui.notesDirty = true
            SetNotesStatus("|cffffd100Unsaved changes|r")
        end
        local text = self:GetText() or ""
        local lines = 0
        for line in string.gmatch(text .. "\n", "(.-)\n") do
            lines = lines + math.max(1, math.ceil(string.len(line) / 30))
        end
        self:SetHeight(math.max(240, lines * 14 + 20))
    end)

    ui.notesStatus = n:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    ui.notesStatus:SetPoint("BOTTOMLEFT", n, "BOTTOMLEFT", 14, 46)

    local save = FlatButton("WrathMentorNotesSave", n, 90, 22)
    save:SetPoint("BOTTOMLEFT", n, "BOTTOMLEFT", 12, 14)
    save:SetText("Save")
    save:SetScript("OnClick", function()
        edit:ClearFocus()
        WM:SaveNotes(false)
    end)

    local close = FlatButton("WrathMentorNotesClose", n, 90, 22)
    close:SetPoint("LEFT", save, "RIGHT", 6, 0)
    close:SetText("Close")
    close:SetScript("OnClick", function() WM:ToggleNotes() end)
end

function WM:ToggleNotes()
    if not ui.main then return end
    if not ui.notes then CreateNotes() end
    if ui.notes:IsShown() then
        if ui.notesDirty then self:SaveNotes(true) end
        ui.notes:Hide()
    else
        ui.notes:Show()
        self:LoadNotes()
    end
end

------------------------------------------------------------------
-- Options synchronisation
------------------------------------------------------------------
local function WindowScaleLabel(value)
    return "Tactics window size: " .. math.floor((value or 1) * 100 + 0.5) .. "%"
end

function WM:RefreshOptions()
    ui.refreshing = true
    if ui.announceCheck then ui.announceCheck:SetChecked(self.db.announce and true or false) end
    if ui.optChecks then
        for _, cb in ipairs(ui.optChecks) do
            cb:SetChecked(cb.getter() and true or false)
        end
    end
    if ui.windowScaleSlider then
        ui.windowScaleSlider:SetValue(self.db.mainScale or 1)
        getglobal("WrathMentorWindowScaleSliderText"):SetText(WindowScaleLabel(self.db.mainScale))
    end
    if ui.windowAlphaSlider then
        ui.windowAlphaSlider:SetValue(self.db.mainAlpha or 1)
        getglobal("WrathMentorWindowAlphaSliderText"):SetText("Window opacity: " .. math.floor((self.db.mainAlpha or 1) * 100 + 0.5) .. "%")
    end
    if ui.sendContentButtons then
        local current = self.db.sendContent or "strategy"
        for key, btn in pairs(ui.sendContentButtons) do
            if key == current then btn:Disable() else btn:Enable() end
        end
    end
    self:RefreshModel()
    ui.refreshing = false
end

function WM:ApplyMainScale()
    if ui.main then ui.main:SetScale(self.db.mainScale or 1) end
    if ui.notes then ui.notes:SetScale(self.db.mainScale or 1) end
end

function WM:ApplyMainAlpha()
    if ui.main then ui.main:SetAlpha(self.db.mainAlpha or 1) end
end

function WM:ApplySettings()
    self:ApplyMainScale()
    self:ApplyMainAlpha()
    self:UpdateMinimapButton()
    self:RefreshOptions()
end

------------------------------------------------------------------
-- Main window
------------------------------------------------------------------
local CreateOptions -- the settings page (built inside the main window, below)
local function CreateMain()
    local f = CreateFrame("Frame", "WrathMentorFrame", UIParent)
    ui.main = f
    f:SetWidth(WM.db.mainWidth or 760)
    f:SetHeight(WM.db.mainHeight or 500)
    f:SetFrameStrata("DIALOG")
    f:SetToplevel(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:SetClampedToScreen(true)
    Flat(f, S.bg)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self) self:StartMoving() end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SavePos(self, "mainPos")
    end)
    f:SetScript("OnHide", function()
        if ui.notesDirty then WM:SaveNotes(true) end
        if ui.viewMode == "copy" then WM:SetViewMode("detail") end
        if ui.settingsShown then WM:ShowSettingsPage(false) end
    end)
    RestorePos(f, "mainPos", "CENTER", "CENTER", 0, 0)
    -- Resizable via the bottom-right corner grip
    if f.SetResizable then f:SetResizable(true) end
    if f.SetMinResize then f:SetMinResize(640, 420) end
    if f.SetMaxResize then f:SetMaxResize(1400, 900) end
    f:Hide()
    tinsert(UISpecialFrames, "WrathMentorFrame")

    local bar = TitleBar(f, "Wrath Mentor - WotLK Raid Tactics", "by " .. (WM.author or "Saranwrap") .. "  -  v" .. WM.version,
        function() f:Hide() end)
    bar:SetFrameLevel(f:GetFrameLevel() + 60)
    ui.titleBar = bar

    -- Settings: opens the settings page inside this window (button reads "Back" while it is open)
    local settings = FlatButton("WrathMentorSettingsButton", bar, 90, 20)
    settings:SetPoint("RIGHT", bar.close, "LEFT", -6, 0)
    settings:SetText("Settings")
    settings:SetScript("OnClick", function() WM:OpenOptions() end)
    ui.settingsButton = settings


    -- Left: raid / boss list (fixed width, stretches taller/shorter with the window)
    local listScroll = CreateFrame("ScrollFrame", "WrathMentorListScroll", f, "UIPanelScrollFrameTemplate")
    listScroll:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -50)
    listScroll:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 20, 58)
    listScroll:SetWidth(LIST_W)
    local listChild = CreateFrame("Frame", nil, listScroll)
    listChild:SetWidth(LIST_W)
    listChild:SetHeight(10)
    listScroll:SetScrollChild(listChild)
    EnableWheel(listScroll)
    ui.listScroll = listScroll
    ui.listChild = listChild

    -- Right: role buttons, size buttons, notes button (one row)
    local prev
    for i, r in ipairs(ROLES) do
        local b = FlatButton("WrathMentorRole" .. r[1], f, r[3], 22)
        b:SetText(r[2])
        if i == 1 then
            b:SetPoint("TOPLEFT", f, "TOPLEFT", 268, -50)
        else
            b:SetPoint("LEFT", prev, "RIGHT", 2, 0)
        end
        local roleKey = r[1]
        b:SetScript("OnClick", function() WM:SetRole(roleKey) end)
        ui.roleButtons[roleKey] = b
        prev = b
    end
    for _, size in ipairs({ 10, 25 }) do
        local b = FlatButton("WrathMentorSize" .. size, f, 34, 22)
        b:SetText(tostring(size))
        b:SetPoint("LEFT", prev, "RIGHT", (size == 10) and 12 or 2, 0)
        local s = size
        b:SetScript("OnClick", function() WM:SetSize(s) end)
        AddTooltip(b, function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:AddLine(s .. "-man version of the tactics")
            GameTooltip:Show()
        end)
        ui.sizeButtons[size] = b
        prev = b
    end
    local nb = FlatButton("WrathMentorNotesButton", f, 64, 20)
    nb:SetPoint("TOPLEFT", f, "TOPLEFT", 268, -76)
    nb:SetText("Notes")
    nb:SetScript("OnClick", function() WM:ToggleNotes() end)
    AddTooltip(nb, function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Personal notes for this boss")
        GameTooltip:AddLine("Opens a side box. Press Save to keep them.", 1, 1, 1)
        GameTooltip:Show()
    end)
    ui.notesButton = nb

    local cb = FlatButton("WrathMentorCopyButton", f, 52, 20)
    cb:SetPoint("LEFT", nb, "RIGHT", 4, 0)
    cb:SetText("Copy")
    cb:SetScript("OnClick", function() WM:ToggleCopy() end)
    AddTooltip(cb, function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Copy text")
        GameTooltip:AddLine("Shows this boss as selectable text: drag to select part, or Select all, then Ctrl+C.", 1, 1, 1, 1)
        GameTooltip:Show()
    end)
    ui.copyButton = cb

    local lb = FlatButton("WrathMentorLootButton", f, 60, 20)
    lb:SetPoint("LEFT", cb, "RIGHT", 4, 0)
    lb:SetText("Loot")
    lb:SetScript("OnClick", function() WM:ToggleLoot() end)
    AddTooltip(lb, function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Loot table")
        GameTooltip:AddLine("What this boss drops in 10 / 25 (and heroic), with drop chances. Also the raid's trash epics and patterns.", 1, 1, 1, 1)
        GameTooltip:Show()
    end)
    ui.lootButton = lb

    -- Right: detail (stretches both ways as the window is resized)
    local detailScroll = CreateFrame("ScrollFrame", "WrathMentorDetailScroll", f, "UIPanelScrollFrameTemplate")
    detailScroll:SetPoint("TOPLEFT", f, "TOPLEFT", 268, -280)
    detailScroll:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -20, 58)
    local detailChild = CreateFrame("Frame", nil, detailScroll)
    detailChild:SetWidth(DETAIL_W)
    detailChild:SetHeight(10)
    detailScroll:SetScrollChild(detailChild)
    EnableWheel(detailScroll)
    ui.detailScroll = detailScroll

    -- Hidden FontString used only to measure word widths for the word-flow
    -- renderer below (never shown itself).
    local measureFS = detailChild:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    measureFS:Hide()
    ui.measureFS = measureFS
    ui.detailChild = detailChild

    -- Copy view (hidden until the Copy button is pressed; stretches with the window too)
    local cf = CreateFrame("Frame", "WrathMentorCopyFrame", f)
    cf:SetPoint("TOPLEFT", f, "TOPLEFT", 268, -280)
    cf:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -20, 58)
    cf:Hide()
    ui.copyFrame = cf

    local selAll = FlatButton("WrathMentorCopySelectAll", cf, 90, 20)
    selAll:SetPoint("TOPLEFT", cf, "TOPLEFT", 0, 0)
    selAll:SetText("Select all")
    selAll:SetScript("OnClick", function()
        ui.copyEdit:SetFocus()
        ui.copyEdit:HighlightText()
    end)

    local hint = cf:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    hint:SetPoint("LEFT", selAll, "RIGHT", 8, 0)
    hint:SetText("Drag with the mouse to select part of the text, then press Ctrl+C.")

    local copyScroll = CreateFrame("ScrollFrame", "WrathMentorCopyScroll", cf, "UIPanelScrollFrameTemplate")
    copyScroll:SetPoint("TOPLEFT", cf, "TOPLEFT", 0, -26)
    copyScroll:SetPoint("BOTTOMRIGHT", cf, "BOTTOMRIGHT", 0, 0)
    EnableWheel(copyScroll)
    ui.copyScroll = copyScroll

    local copyEdit = CreateFrame("EditBox", "WrathMentorCopyEdit", copyScroll)
    copyEdit:SetMultiLine(true)
    copyEdit:SetAutoFocus(false)
    copyEdit:SetFontObject(ChatFontNormal)
    copyEdit:SetWidth(DETAIL_W - 6)
    copyEdit:SetHeight(324)
    copyEdit:SetMaxLetters(60000)
    copyScroll:SetScrollChild(copyEdit)
    -- Read-only: any typing or pasting is undone immediately, selecting and copying still work
    copyEdit:SetScript("OnTextChanged", function(self, userInput)
        if userInput and ui.copyText then self:SetText(ui.copyText) end
    end)
    copyEdit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    ui.copyEdit = copyEdit

    -- Hidden text used only to measure how tall the copy text is
    local measure = cf:CreateFontString(nil, "ARTWORK", "ChatFontNormal")
    measure:SetWidth(DETAIL_W - 6)
    measure:SetJustifyH("LEFT")
    measure:Hide()
    ui.copyMeasure = measure

    -- Persistent 3D model preview - the whole thing is wrapped in pcall, since if
    -- the "PlayerModel" widget type or any part of its setup isn't supported on
    -- this client, that must NEVER be able to break the rest of the window (the
    -- boss list, the strategy text, Copy/Position, or the Settings button that
    -- come after this in the file). If it fails, the preview just doesn't
    -- appear and its Settings checkbox silently does nothing - nothing else in
    -- the addon is affected either way.
    -- Fixed at the top of the window (NOT inside the scrolling content) - 3D
    -- PlayerModel widgets are known to render incorrectly, or not at all, when
    -- placed inside a ScrollFrame's scroll child (a documented WoW UI engine
    -- quirk, not something fixable from addon code), so the model has to stay
    -- pinned here rather than scroll away with the text.
    pcall(function()
        local mp = CreateFrame("Frame", "WrathMentorModelPreview", f)
        mp:SetPoint("TOPRIGHT", f, "TOPRIGHT", -20, -104)
        mp:SetWidth(195)
        mp:SetHeight(165)

        -- Model is the native WoW 3D creature viewer - a real, live model, not an
        -- image. Not draggable/zoomable with the mouse (that wasn't working
        -- correctly) - it just shows the boss at a fixed, sensible angle. No name
        -- label above it - the big boss-name heading elsewhere covers that. No
        -- hover tooltip either; turning it off is still available in Settings
        -- ("Show the 3D boss model preview") and via /wm models, just not
        -- advertised here.
        local model = CreateFrame("PlayerModel", "WrathMentorModel", mp)
        model:SetPoint("TOPRIGHT", mp, "TOPRIGHT", 0, 0)
        model:SetWidth(142)
        model:SetHeight(158)

        -- Only published to the shared ui table once every step above succeeded -
        -- if anything failed partway through, ui.modelPreview/ui.model simply stay
        -- nil, and RefreshModel() already checks for that before touching them.
        -- Placeholder in the exact spot the model uses: the Wrath Mentor
        -- artwork (no box or outline) and a line saying the model loads once
        -- the boss is targeted. Hidden as soon as a real model is shown.
        local ph = CreateFrame("Frame", "WrathMentorModelPlaceholder", mp)
        ph:SetAllPoints(model)
        local skull = ph:CreateTexture(nil, "ARTWORK")
        skull:SetWidth(124)
        skull:SetHeight(124)
        skull:SetPoint("TOP", ph, "TOP", 0, 0)
        skull:SetTexture(WM.media .. "placeholder")
        local phText = ph:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        phText:SetPoint("TOP", skull, "BOTTOM", 0, -4)
        phText:SetWidth(132)
        phText:SetJustifyH("CENTER")
        phText:SetTextColor(0.75, 0.75, 0.8)
        ph.text = phText
        ph:Hide()
        ui.modelPlaceholder = ph

        ui.modelPreview = mp
        ui.model = model
    end)

    -- Big centered boss-name heading, to the left of the model preview - also
    -- fixed (paired visually with the model, which can't scroll - see above).
    -- Uses WoW's own default UI font (Friz Quadrata) at a large size, refreshed
    -- by WM:RefreshBossNameHeading() whenever the selected boss changes.
    local bossNameFS = f:CreateFontString(nil, "ARTWORK")
    bossNameFS:SetPoint("TOPLEFT", f, "TOPLEFT", 268, -104)
    bossNameFS:SetPoint("BOTTOMRIGHT", f, "TOPRIGHT", -235, -280)
    bossNameFS:SetJustifyH("CENTER")
    bossNameFS:SetJustifyV("MIDDLE")
    ui.bossNameHeading = bossNameFS

    -- Bottom: send + option + settings
    local send = FlatButton("WrathMentorSendButton", f, 120, 24)
    send:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 260, 14)
    send:SetText("Send to chat")
    send:SetScript("OnClick", function() WM:Send(WM.selected) end)
    ui.sendButton = send


    -- Drag-to-resize grip in the bottom-right corner
    local grip = ResizeGrip(f, function()
        WM.db.mainWidth = f:GetWidth()
        WM.db.mainHeight = f:GetHeight()
        WM:LayoutMain()
    end)
    ui.resizeGrip = grip
    grip:SetFrameLevel(f:GetFrameLevel() + 70)

    CreateOptions()
    if WM.CreateLootView then WM:CreateLootView(f) end

    -- Re-wrap text when the window is resized (by the grip, or SetWidth/SetHeight from saved state)
    f:SetScript("OnSizeChanged", function(self, w, h)
        WM:LayoutMain()
    end)
end

-- Re-applies the current window width to the detail/copy panes and re-wraps their text.
-- Called after a resize (grip drag) and whenever the window is (re)created.
function WM:LayoutMain()
    if not ui.detailScroll then return end
    local dw = ui.detailScroll:GetWidth()
    if dw and dw > 0 and ui.detailChild then ui.detailChild:SetWidth(dw) end
    if ui.copyScroll then
        local cw = ui.copyScroll:GetWidth()
        if cw and cw > 0 then
            if ui.copyEdit then ui.copyEdit:SetWidth(cw - 6) end
            if ui.copyMeasure then ui.copyMeasure:SetWidth(cw - 6) end
        end
    end
    if ui.main and ui.main:IsShown() then
        self:RefreshDetail()
        self:RefreshActiveView()
    end
end

function WM:ShowMain(boss)
    local firstCreate = not ui.main
    if firstCreate then CreateMain() end
    if boss and boss ~= self.selected and ui.notesDirty then self:SaveNotes(true) end
    if boss then
        self.selected = boss
    elseif not self.selected then
        local raid = self:GetZoneRaid() or self.raids[self.raidOrder[1]]
        self.selected = raid.bosses[1]
    end
    self.collapsed[self.selected.raidId] = false
    ui.main:Show()
    if firstCreate then self:ApplyMainScale() end
    self:RefreshOptions()
    self:RefreshList()
    self:LayoutMain()
    self:LoadNotes()
end

function WM:ToggleMain()
    if ui.main and ui.main:IsShown() then
        ui.main:Hide()
    else
        self:ShowMain()
    end
end

function WM:ResetPositions()
    if ui.main then
        RestorePos(ui.main, "mainPos", "CENTER", "CENTER", 0, 0)
        ui.main:SetWidth(WM.db.mainWidth or 760)
        ui.main:SetHeight(WM.db.mainHeight or 500)
        self:LayoutMain()
    end
end

------------------------------------------------------------------
-- Settings window (its own standalone addon window, opened via /wm config,
-- the "Settings" button in the main window, or right-clicking the minimap
-- button) - same visual style as the main tactics window.
------------------------------------------------------------------
local CHECK_OPTIONS = {
    {
        label = "Show TL;DR in chat when I target a boss",
        test = function()
            local boss = WM.selected or WM.raids[WM.raidOrder[1]].bosses[1]
            WM:AnnounceBoss(boss)
        end,
        get = function() return WM.db.announce end,
        set = function(v) WM.db.announce = v end,
    },
    {
        label = "Only announce inside raid instances",
        get = function() return WM.db.announceRaidOnly end,
        set = function(v) WM.db.announceRaidOnly = v end,
    },
    {
        label = "Show the 3D boss model preview",
        get = function() return WM.db.modelsEnabled end,
        set = function(v) WM.db.modelsEnabled = v end,
    },
    {
        label = "Show the minimap button",
        get = function() return not WM.db.minimap.hide end,
        set = function(v) WM.db.minimap.hide = not v; WM:UpdateMinimapButton() end,
    },
}

------------------------------------------------------------------
-- Minimap button (hand-made, no libraries needed)
------------------------------------------------------------------
local function MinimapButton_UpdatePosition()
    if not ui.minimap then return end
    local angle = math.rad(WM.db.minimap.angle or 225)
    local radius = (Minimap:GetWidth() / 2) + 10
    ui.minimap:ClearAllPoints()
    ui.minimap:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
end

local function MinimapButton_OnDragUpdate()
    local mx, my = Minimap:GetCenter()
    local scale = Minimap:GetEffectiveScale()
    local px, py = GetCursorPosition()
    px, py = px / scale, py / scale
    WM.db.minimap.angle = math.deg(math.atan2(py - my, px - mx))
    MinimapButton_UpdatePosition()
end

local function CreateMinimapButton()
    if ui.minimap then return end
    local b = CreateFrame("Button", "WrathMentorMinimapButton", Minimap)
    ui.minimap = b
    b:SetWidth(31)
    b:SetHeight(31)
    b:SetFrameStrata("MEDIUM")
    b:SetFrameLevel(Minimap:GetFrameLevel() + 8)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    b:RegisterForDrag("LeftButton")
    b:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local overlay = b:CreateTexture(nil, "OVERLAY")
    overlay:SetWidth(53)
    overlay:SetHeight(53)
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    overlay:SetPoint("TOPLEFT", b, "TOPLEFT", 0, 0)

    local background = b:CreateTexture(nil, "BACKGROUND")
    background:SetWidth(20)
    background:SetHeight(20)
    background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    background:SetPoint("TOPLEFT", b, "TOPLEFT", 7, -5)

    -- Wrath Mentor logo (textures\minimap.tga, 64x64 with transparency)
    local icon = b:CreateTexture(nil, "ARTWORK")
    icon:SetWidth(21)
    icon:SetHeight(21)
    icon:SetTexture(WM.media .. "minimap")
    icon:SetPoint("TOPLEFT", b, "TOPLEFT", 6, -5)

    b:SetScript("OnClick", function(self, button)
        if button == "RightButton" then
            WM:OpenOptions()
        else
            WM:ToggleMain()
        end
    end)
    b:SetScript("OnDragStart", function(self)
        GameTooltip:Hide()
        self:LockHighlight()
        self:SetScript("OnUpdate", MinimapButton_OnDragUpdate)
    end)
    b:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
        self:UnlockHighlight()
    end)
    b:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("Wrath Mentor")
        GameTooltip:AddLine("Left-click: open the tactics window", 1, 1, 1)
        GameTooltip:AddLine("Right-click: settings", 1, 1, 1)
        GameTooltip:AddLine("Drag: move this button", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

function WM:UpdateMinimapButton()
    if not ui.minimap then CreateMinimapButton() end
    if not ui.minimap then return end
    if self.db.minimap.hide then
        ui.minimap:Hide()
    else
        MinimapButton_UpdatePosition()
        ui.minimap:Show()
    end
end

function CreateOptions()
    if ui.options or not ui.main then return end
    -- The settings page lives inside the main window: it covers the content
    -- area (below the title bar) and scrolls. The title bar's Settings button
    -- opens it and turns into "Back".
    local f = ui.main
    local cover = CreateFrame("Frame", "WrathMentorOptionsPage", f)
    cover:SetPoint("TOPLEFT", f, "TOPLEFT", 1, -31)
    cover:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -1, 1)
    cover:SetFrameLevel(f:GetFrameLevel() + 50)
    cover:EnableMouse(true)
    local coverBg = cover:CreateTexture(nil, "BACKGROUND")
    coverBg:SetAllPoints(cover)
    coverBg:SetTexture(S.bg[1], S.bg[2], S.bg[3], 1)
    cover:Hide()
    ui.optionsPage = cover

    local scroll = CreateFrame("ScrollFrame", "WrathMentorOptionsScroll", cover, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", cover, "TOPLEFT", 0, -4)
    scroll:SetPoint("BOTTOMRIGHT", cover, "BOTTOMRIGHT", -26, 20)
    EnableWheel(scroll)
    local p = CreateFrame("Frame", "WrathMentorOptions", scroll)
    p:SetWidth(600)
    p:SetHeight(740)
    scroll:SetScrollChild(p)
    ui.options = p
    ui.optionsScroll = scroll
    cover:SetScript("OnSizeChanged", function(self)
        local w = scroll:GetWidth()
        if w and w > 0 then p:SetWidth(w) end
    end)

    local sub = p:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    sub:SetPoint("TOPLEFT", p, "TOPLEFT", 16, -12)
    sub:SetText("WotLK raid tactics. Changes apply immediately. Type /wm help for commands.")

    local defaults = FlatButton("WrathMentorDefaultsButton", p, 140, 20)
    defaults:SetPoint("TOPLEFT", p, "TOPLEFT", 420, -10)
    defaults:SetText("Default settings")
    defaults:SetScript("OnClick", function() WM:ResetOptions() end)

    local y = -45
    for i, opt in ipairs(CHECK_OPTIONS) do
        local cb = CreateFrame("CheckButton", "WrathMentorOpt" .. i, p, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", p, "TOPLEFT", 14, y)
        getglobal("WrathMentorOpt" .. i .. "Text"):SetText(opt.label)
        cb.getter = opt.get
        cb:SetScript("OnClick", function(self)
            if ui.refreshing then return end
            opt.set(self:GetChecked() and true or false)
            WM:ApplySettings()
        end)
        ui.optChecks[#ui.optChecks + 1] = cb
        if opt.test then
            -- small "Test" button right after the checkbox text
            local tb = FlatButton("WrathMentorOpt" .. i .. "Test", p, 48, 18)
            tb:SetPoint("LEFT", getglobal("WrathMentorOpt" .. i .. "Text"), "RIGHT", 10, 0)
            tb:SetText("Test")
            tb:SetScript("OnClick", opt.test)
            AddTooltip(tb, function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:AddLine("Show the TL;DR announcement now")
                GameTooltip:AddLine("Prints what you'd see in chat when you target the selected boss (only you see it).", 1, 1, 1, 1)
                GameTooltip:Show()
            end)
        end
        y = y - 28
    end

    local wslider = CreateFrame("Slider", "WrathMentorWindowScaleSlider", p, "OptionsSliderTemplate")
    wslider:SetPoint("TOPLEFT", p, "TOPLEFT", 24, y - 20)
    wslider:SetWidth(240)
    wslider:SetMinMaxValues(0.7, 1.5)
    wslider:SetValueStep(0.05)
    getglobal("WrathMentorWindowScaleSliderLow"):SetText("70%")
    getglobal("WrathMentorWindowScaleSliderHigh"):SetText("150%")
    wslider:SetScript("OnValueChanged", function(self, value)
        if ui.refreshing then return end
        value = math.floor(value * 20 + 0.5) / 20
        WM.db.mainScale = value
        getglobal("WrathMentorWindowScaleSliderText"):SetText(WindowScaleLabel(value))
        WM:ApplyMainScale()
    end)
    ui.windowScaleSlider = wslider
    y = y - 60

    local aslider = CreateFrame("Slider", "WrathMentorWindowAlphaSlider", p, "OptionsSliderTemplate")
    aslider:SetPoint("TOPLEFT", p, "TOPLEFT", 24, y - 20)
    aslider:SetWidth(240)
    aslider:SetMinMaxValues(0, 1)
    aslider:SetValueStep(0.05)
    getglobal("WrathMentorWindowAlphaSliderLow"):SetText("0%")
    getglobal("WrathMentorWindowAlphaSliderHigh"):SetText("100%")
    aslider:SetScript("OnValueChanged", function(self, value)
        if ui.refreshing then return end
        value = math.floor(value * 20 + 0.5) / 20
        WM.db.mainAlpha = value
        getglobal("WrathMentorWindowAlphaSliderText"):SetText("Window opacity: " .. math.floor(value * 100 + 0.5) .. "%")
        WM:ApplyMainAlpha()
    end)
    ui.windowAlphaSlider = aslider
    y = y - 60

    -- "Send to chat" content selector - three mutually-exclusive buttons, same
    -- pattern as the role/size buttons in the main window (disabled = selected).
    local sendLabel = p:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    sendLabel:SetPoint("TOPLEFT", p, "TOPLEFT", 16, y - 20)
    sendLabel:SetText('"Send to chat" sends:')
    local SEND_OPTS = { { key = "strategy", label = "Strategy" }, { key = "hard", label = "Hard Mode" }, { key = "tldr", label = "TL;DR" } }
    ui.sendContentButtons = {}
    local prevSendBtn
    for _, opt in ipairs(SEND_OPTS) do
        local b = FlatButton(nil, p, 90, 20)
        if prevSendBtn then
            b:SetPoint("LEFT", prevSendBtn, "RIGHT", 4, 0)
        else
            b:SetPoint("TOPLEFT", sendLabel, "BOTTOMLEFT", 0, -4)
        end
        b:SetText(opt.label)
        b:SetScript("OnClick", function()
            WM.db.sendContent = opt.key
            WM:RefreshOptions()
        end)
        ui.sendContentButtons[opt.key] = b
        prevSendBtn = b
    end
    y = y - 60

    local test = FlatButton("WrathMentorTestButton", p, 150, 22)
    test:SetPoint("TOPLEFT", p, "TOPLEFT", 16, y - 10)
    test:SetText("Test send to chat")
    test:SetScript("OnClick", function()
        local boss = WM.selected or WM.raids[WM.raidOrder[1]].bosses[1]
        WM:PreviewSend(boss)
    end)
    AddTooltip(test, function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Preview \"Send to chat\"")
        GameTooltip:AddLine("Shows in your chat frame exactly what would be posted for the selected boss, using the Strategy / Hard Mode / TL;DR choice above. Nothing is sent to anyone.", 1, 1, 1, 1)
        GameTooltip:Show()
    end)

    -- right under "Default settings", same width, right-aligned with it
    local reset = FlatButton("WrathMentorResetButton", p, 140, 20)
    reset:SetPoint("TOPRIGHT", defaults, "BOTTOMRIGHT", 0, -4)
    reset:SetText("Reset position/size")
    reset:SetScript("OnClick", function() WM:HandleSlash("reset") end)
    y = y - 40

    -- Every everyday slash command, one per line, for reference so you don't
    -- have to remember /wm help. Plain static text now, not a scrolling box -
    -- test/diagnostic commands (/wm modeltest, /wm checklinks) are left off
    -- this list on purpose so they're not something people stumble into and
    -- start poking at; both still work fine if you type them directly.
    local cmdLabel = p:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    cmdLabel:SetPoint("TOPLEFT", p, "TOPLEFT", 16, y - 20)
    cmdLabel:SetText("Slash commands")

    local cmdText = p:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    cmdText:SetPoint("TOPLEFT", cmdLabel, "BOTTOMLEFT", 0, -6)
    cmdText:SetWidth(540)
    cmdText:SetJustifyH("LEFT")
    cmdText:SetText(
        "/wm - open or close the window\n" ..
        "/wm <boss name> - jump straight to a boss (partial names work)\n" ..
        "/wm role all||tank||heal||dps - filter role tips\n" ..
        "/wm size 10||25 - switch raid size\n" ..
        "/wm notes - open/close personal notes\n" ..
        "/wm announce - toggle the chat TL;DR when you target a boss\n" ..
        "/wm models - toggle the 3D model preview\n" ..
        "/wm minimap - toggle the minimap button\n" ..
        "/wm send [raid||party||say] - send the current boss to chat\n" ..
        "/wm loot - open / close the loot table of the selected boss\n" ..
        "/wm config - open / close this settings page\n" ..
        "/wm reset - reset window position/size"
    )
    -- Advance by the TEXT'S ACTUAL rendered height, not a guessed fixed
    -- number - a guess is exactly what caused this to overlap the Links
    -- section below it last time, once the line count changed.
    y = y - 20 - (cmdText:GetStringHeight() or 180) - 20

    -- Links - real (read-only) EditBoxes, not plain text, so the URL can
    -- actually be selected and copied (click the box, Ctrl+A, Ctrl+C).
    local linkLabel = p:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    linkLabel:SetPoint("TOPLEFT", p, "TOPLEFT", 16, y - 20)
    linkLabel:SetText("Links (click a box, Ctrl+A then Ctrl+C to copy)")

    -- One line per link: [icon or label] + the URL right next to it. The URL
    -- is still a real (read-only) EditBox so it can be selected and copied.
    -- iconPath: optional texture shown instead of the text label (16x16).
    local function LinkBox(name, anchorTo, labelText, url, iconPath)
        local lead
        if iconPath then
            lead = p:CreateTexture(nil, "ARTWORK")
            lead:SetWidth(16)
            lead:SetHeight(16)
            lead:SetTexture(iconPath)
        else
            lead = p:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
            lead:SetWidth(60)
            lead:SetHeight(16)
            lead:SetJustifyH("LEFT")
            lead:SetText(labelText)
        end
        lead:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT", 0, -10)

        local box = CreateFrame("EditBox", name, p)
        box:SetPoint("LEFT", lead, "RIGHT", iconPath and 8 or 4, 0)
        box:SetWidth(440)
        box:SetHeight(16)
        box:SetFontObject(GameFontHighlightSmall)
        box:SetAutoFocus(false)
        box:SetText(url)
        box:SetCursorPosition(0)
        -- Read-only: any typing/pasting is undone immediately, selecting and
        -- copying still work fine (same trick the Copy view uses).
        box:SetScript("OnTextChanged", function(self, userInput)
            if userInput then self:SetText(url) end
        end)
        box:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
        box:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        return lead, box
    end

    local ghLead = LinkBox("WrathMentorGitHubLink", linkLabel, "GitHub", "https://github.com/saranwrap04/Wrath-Mentor",
        WM.media .. "github")
    LinkBox("WrathMentorWarperiaLink", ghLead, "Warperia", "https://warperia.com/addon-wotlk/wrath-mentor/",
        WM.media .. "warperia")

    cover:SetScript("OnShow", function() WM:RefreshOptions() end)
end

-- Shows / hides the settings page inside the main window
function WM:ShowSettingsPage(show)
    if not ui.optionsPage then return end
    ui.settingsShown = show and true or false
    if show then ui.optionsPage:Show() else ui.optionsPage:Hide() end
    if ui.settingsButton then ui.settingsButton:SetText(show and "Back" or "Settings") end
    self:RefreshModel()
    if show then self:RefreshOptions() end
end

function WM:OpenOptions()
    if not ui.main or not ui.main:IsShown() then
        self:ShowMain()
        self:ShowSettingsPage(true)
        return
    end
    self:ShowSettingsPage(not ui.settingsShown)
end

function WM:SetupUI()
    CreateMinimapButton()
end

-- shared look for LootView.lua
WM.UIH = { S = S, Flat = Flat, FlatButton = FlatButton, AddTooltip = AddTooltip, ui = ui }

-- Applying the saved window scale is deferred to ShowMain (below), since the
-- window itself is only created the first time it is shown.
