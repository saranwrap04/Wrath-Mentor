-- Wrath Mentor - Loot view
-- The selected boss's loot (10 / 25 from the size buttons, Heroic where the
-- raid has it) with drop chances, plus the raid's trash epics and patterns.
-- Data: LootData.lua (worked out from the AzerothCore world database).

local WM = WrathMentor
local ROWS_MAX, ROW_H = 40, 20

-- Wrath Mentor boss names that are spelled differently in the loot data
local ALIAS = { ["Icecrown Gunship Battle"] = "Gunship Battle" }

local function H() return WM.UIH end
local function Data() return WrathMentor_LootData end

local QUALITY = { [2] = "|cff1eff00", [3] = "|cff0070dd", [4] = "|cffa335ee", [5] = "|cffff8000" }

local function Parse(str)
    local list = {}
    for entry in (str or ""):gmatch("[^,]+") do
        local id, pct, hm, src = entry:match("^(%d+):([%d%.]+):?(%a*):?(%d*)$")
        if id then list[#list + 1] = { id = tonumber(id), pct = tonumber(pct), hm = hm == "h", src = tonumber(src) } end
    end
    return list
end

local function ItemInfo(id)
    local d = Data().items[id]
    local name, link, q = GetItemInfo(id)
    q = q or (d and d[2]) or 4
    name = name or (d and d[1]) or ("item " .. id)
    if not link then
        link = (QUALITY[q] or "|cffa335ee") .. "|Hitem:" .. id .. ":0:0:0:0:0:0:0:0|h[" .. name .. "]|h|r"
    end
    return name, link, q, d and d[3] or "", d and d[4] or 0, d and d[5]
end

-- " A" (Alliance only, blue) / " H" (Horde only, red) after the item name
local FACTION_TAG = { A = " |cff4a9effA|r", H = " |cffff4a4aH|r" }

-- column sorting (click a column title)
local SORT_DEFAULT_DESC = { ilvl = true, pct = true }
local function SortRows(rows, key, desc)
    if not key then return end
    local function val(r)
        local name, _, _, typ, ilvl = ItemInfo(r.id)
        if key == "name" then return string.lower(name)
        elseif key == "type" then return string.lower(typ)
        elseif key == "ilvl" then return ilvl
        else return r.pct end
    end
    for i, r in ipairs(rows) do r._k, r._i = val(r), i end
    table.sort(rows, function(a, b)
        if a._k ~= b._k then
            if desc then return a._k > b._k else return a._k < b._k end
        end
        return a._i < b._i
    end)
end

local function ItemIcon(id)
    local icon = GetItemIcon and GetItemIcon(id)
    if not icon then icon = select(10, GetItemInfo(id)) end
    return icon or "Interface\\Icons\\INV_Misc_QuestionMark"
end

-- loot-data raid + boss index for a Wrath Mentor boss
function WM:LootFor(boss)
    if not Data() or not boss then return end
    local raid = self.raids[boss.raidId]
    local want = ALIAS[boss.name] or boss.name
    for _, r in ipairs(Data().raids) do
        if r.name == (raid and raid.name) then
            for bi, b in ipairs(r.bosses) do
                if b.name == want then return r, bi end
            end
            return r, nil
        end
    end
end

---------------------------------------------------------------------------
-- Rows
---------------------------------------------------------------------------
local function CreateRow(parent, i)
    local S = H().S
    local row = CreateFrame("Button", nil, parent)
    row:SetHeight(ROW_H)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 1, -1 - (i - 1) * ROW_H)
    row:SetPoint("RIGHT", parent, "RIGHT", -1, 0)
    local stripe = row:CreateTexture(nil, "BACKGROUND")
    stripe:SetAllPoints(row)
    stripe:SetTexture(1, 1, 1, (i % 2 == 0) and 0.03 or 0)
    local hl = row:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints(row)
    hl:SetTexture(S.accent[1], S.accent[2], S.accent[3], 0.12)
    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetWidth(16); icon:SetHeight(16)
    icon:SetPoint("LEFT", row, "LEFT", 4, 0)
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    local name = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    name:SetPoint("LEFT", row, "LEFT", 26, 0)
    name:SetHeight(ROW_H); name:SetJustifyH("LEFT")
    local pct = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    pct:SetPoint("RIGHT", row, "RIGHT", -6, 0)
    pct:SetWidth(50); pct:SetHeight(ROW_H); pct:SetJustifyH("RIGHT")
    local ilvl = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    ilvl:SetPoint("RIGHT", pct, "LEFT", -6, 0)
    ilvl:SetWidth(30); ilvl:SetHeight(ROW_H); ilvl:SetJustifyH("RIGHT")
    local typ = row:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    typ:SetHeight(ROW_H); typ:SetJustifyH("LEFT")
    row.icon, row.nameFS, row.typeFS, row.ilvlFS, row.pctFS = icon, name, typ, ilvl, pct

    row:SetScript("OnClick", function(self)
        local r = self.data
        if not r then return end
        local _, link = ItemInfo(r.id)
        if IsControlKeyDown() and DressUpItemLink then DressUpItemLink(link)
        elseif IsShiftKeyDown() and ChatEdit_InsertLink then ChatEdit_InsertLink(link) end
    end)
    row:SetScript("OnEnter", function(self)
        local r = self.data
        if not r then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink("item:" .. r.id)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Drop chance: " .. r.pct .. "%" .. (r.hm and "  (hard mode)" or ""), 1, 0.82, 0)
        if r.where then GameTooltip:AddLine("From: " .. r.where, 1, 1, 1) end
        local fac = select(6, ItemInfo(r.id))
        if fac == "A" then GameTooltip:AddLine("Alliance only", 0.29, 0.62, 1)
        elseif fac == "H" then GameTooltip:AddLine("Horde only", 1, 0.29, 0.29) end
        GameTooltip:AddLine("Shift-click: link in chat   Ctrl-click: try it on", 0.6, 0.6, 0.6)
        GameTooltip:Show()
    end)
    row:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return row
end

---------------------------------------------------------------------------
-- View
---------------------------------------------------------------------------
function WM:CreateLootView(main)
    if not Data() then return end
    local h = H()
    local ui, S = h.ui, h.S
    local f = CreateFrame("Frame", "WrathMentorLootFrame", main)
    f:SetPoint("TOPLEFT", main, "TOPLEFT", 268, -104)
    f:SetPoint("BOTTOMRIGHT", main, "BOTTOMRIGHT", -20, 58)
    f:Hide()
    ui.lootFrame = f
    ui.lootSection = "boss"

    local title = f:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    title:SetJustifyH("LEFT")
    ui.lootTitle = title

    -- Section buttons: Boss | Trash | Patterns | (Tribute) + Heroic
    ui.lootSectionBtns = {}
    local prev
    for _, sec in ipairs({ { "boss", "Boss loot", 76 }, { "trash", "Trash", 56 }, { "patterns", "Patterns", 70 }, { "extra", "", 70 } }) do
        local b = h.FlatButton(nil, f, sec[3], 20)
        if prev then b:SetPoint("LEFT", prev, "RIGHT", 4, 0) else b:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -24) end
        b:SetText(sec[2])
        b:SetScript("OnClick", function() ui.lootSection = sec[1]; WM:RefreshLoot() end)
        ui.lootSectionBtns[sec[1]] = b
        prev = b
    end
    local hc = h.FlatButton(nil, f, 64, 20)
    hc:SetPoint("LEFT", prev, "RIGHT", 12, 0)
    hc:SetText("Heroic")
    hc:SetScript("OnClick", function() WM.db.lootHeroic = not WM.db.lootHeroic; WM:RefreshLoot() end)
    h.AddTooltip(hc, function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Heroic loot")
        GameTooltip:AddLine("Show the heroic version (Trial of the Crusader, Icecrown Citadel, Ruby Sanctum). 10 / 25 follows the size buttons above.", 1, 1, 1, 1)
        GameTooltip:Show()
    end)
    ui.lootHeroicBtn = hc

    -- Back to the tactics page (same as the Tactics button above)
    local back = h.FlatButton(nil, f, 70, 20)
    back:SetPoint("TOPRIGHT", f, "TOPRIGHT", -24, -24)
    back:SetText("Back")
    back:SetScript("OnClick", function() WM:SetViewMode("detail") end)
    h.AddTooltip(back, function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Back to the tactics")
        GameTooltip:Show()
    end)
    ui.lootBackBtn = back

    local header = CreateFrame("Frame", nil, f)
    header:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -50)
    header:SetPoint("RIGHT", f, "RIGHT", -24, 0)
    header:SetHeight(18)
    h.Flat(header, S.band)
    -- clickable column titles: click to sort, click again to reverse
    ui.lootHeaders = {}
    local function Head(key, label, justify)
        local b = CreateFrame("Button", nil, header)
        b:SetHeight(18)
        local fs = b:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        fs:SetAllPoints(b)
        fs:SetJustifyH(justify)
        b.fs, b.label = fs, label
        b:SetScript("OnClick", function()
            if ui.lootSortKey == key then
                ui.lootSortDesc = not ui.lootSortDesc
            else
                ui.lootSortKey, ui.lootSortDesc = key, SORT_DEFAULT_DESC[key] or false
            end
            WM:RefreshLoot()
        end)
        b:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:AddLine("Sort by " .. label)
            GameTooltip:AddLine("Click again to reverse.", 0.8, 0.8, 0.8)
            GameTooltip:Show()
        end)
        b:SetScript("OnLeave", function() GameTooltip:Hide() end)
        ui.lootHeaders[key] = b
        return b
    end
    local h1 = Head("name", "Item", "LEFT"); h1:SetPoint("LEFT", header, "LEFT", 8, 0); h1:SetWidth(150)
    local h2 = Head("type", "Type", "LEFT"); h2:SetWidth(120)
    local h4 = Head("pct", "Chance", "RIGHT"); h4:SetPoint("RIGHT", header, "RIGHT", -7, 0); h4:SetWidth(56)
    local h3 = Head("ilvl", "iLvl", "RIGHT"); h3:SetPoint("RIGHT", h4, "LEFT", -4, 0); h3:SetWidth(40)
    ui.lootTypeHeader = h2
    ui.lootNameHeader = h1

    local list = CreateFrame("Frame", nil, f)
    list:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -2)
    list:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -24, 14)
    h.Flat(list, S.panel)
    ui.lootList = list
    ui.lootRows = {}
    for i = 1, ROWS_MAX do ui.lootRows[i] = CreateRow(list, i) end
    local scroll = CreateFrame("ScrollFrame", "WrathMentorLootScroll", list, "FauxScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", list, "TOPLEFT", 0, -1)
    scroll:SetPoint("BOTTOMRIGHT", list, "BOTTOMRIGHT", -2, 1)
    scroll:SetScript("OnVerticalScroll", function(sf, offset)
        FauxScrollFrame_OnVerticalScroll(sf, offset, ROW_H, function() WM:RefreshLoot() end)
    end)
    ui.lootScroll = scroll
    local empty = list:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    empty:SetPoint("CENTER", list, "CENTER", 0, 0)
    ui.lootEmpty = empty
    local foot = f:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    foot:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)
    foot:SetText("HM = hard mode,  |cff4a9effA|r / |cffff4a4aH|r = Alliance / Horde only.  Click a column title to sort.")
    ui.lootFoot = foot

    f:SetScript("OnSizeChanged", function() WM:RefreshLoot() end)
end

function WM:RefreshLoot()
    local ui = self.ui
    if not ui.lootFrame or not ui.lootFrame:IsShown() then return end
    local h = H()
    local boss = self.selected
    local raid, bossIdx = self:LootFor(boss)

    -- extra section (Tribute chest in Trial of the Crusader)
    local extraIdx, trashIdx, patIdx
    if raid then
        for bi, b in ipairs(raid.bosses) do
            if b.patterns then patIdx = bi
            elseif b.name == "Trash mobs" then trashIdx = bi
            else
                local isWM = false
                for _, wb in ipairs(self.raids[boss.raidId].bosses) do
                    if (ALIAS[wb.name] or wb.name) == b.name then isWM = true end
                end
                if not isWM then extraIdx = bi end
            end
        end
    end
    local btns = ui.lootSectionBtns
    if extraIdx then
        btns.extra:SetText(raid.bosses[extraIdx].name:match("Tribute") and "Tribute" or raid.bosses[extraIdx].name)
        btns.extra:Show()
    else
        btns.extra:Hide()
        if ui.lootSection == "extra" then ui.lootSection = "boss" end
    end
    if trashIdx then btns.trash:Show() else btns.trash:Hide(); if ui.lootSection == "trash" then ui.lootSection = "boss" end end
    if patIdx then btns.patterns:Show() else btns.patterns:Hide(); if ui.lootSection == "patterns" then ui.lootSection = "boss" end end
    for key, b in pairs(btns) do
        if key == ui.lootSection then b:Disable() else b:Enable() end
    end

    -- mode: size buttons + Heroic
    local hasHC = false
    for _, m in ipairs(raid and raid.modes or {}) do if m:find("H") then hasHC = true end end
    local mode = tostring(self:GetSize())
    if hasHC then
        ui.lootHeroicBtn:Show()
        if self.db.lootHeroic then ui.lootHeroicBtn:Disable(); mode = mode .. "H" else ui.lootHeroicBtn:Enable() end
    else
        ui.lootHeroicBtn:Hide()
    end

    local idx = (ui.lootSection == "trash" and trashIdx) or (ui.lootSection == "patterns" and patIdx)
        or (ui.lootSection == "extra" and extraIdx) or bossIdx
    local entry = raid and idx and raid.bosses[idx]
    local label = (ui.lootSection == "boss") and (boss and boss.name or "") or (entry and entry.name or "")
    ui.lootTitle:SetText(label .. "  |cff9d9d9d" .. self:GetSize() .. "-man" .. (mode:find("H") and " Heroic" or "") .. "|r")

    local rows = {}
    if entry and entry.loot then
        for _, r in ipairs(Parse(entry.loot[mode])) do
            if r.src then
                r.where = (r.src == 0) and "Trash mobs" or (raid.bosses[r.src] and raid.bosses[r.src].name)
            end
            rows[#rows + 1] = r
        end
    end

    -- layout + rows
    local listH = ui.lootList:GetHeight() or 200
    local listW = ui.lootList:GetWidth() or 400
    local shown = math.max(1, math.min(ROWS_MAX, math.floor((listH - 2) / ROW_H)))
    local nameW = math.floor((listW - 26 - 96) * 0.55)
    ui.lootTypeHeader:ClearAllPoints()
    ui.lootTypeHeader:SetPoint("LEFT", ui.lootTypeHeader:GetParent(), "LEFT", 26 + nameW + 8, 0)
    ui.lootTypeHeader:SetWidth(math.max(40, listW - 26 - nameW - 8 - 96))
    ui.lootNameHeader:SetWidth(nameW + 18)
    for key, b in pairs(ui.lootHeaders) do
        if key == ui.lootSortKey then
            b.fs:SetText("|cffffffff" .. b.label .. (ui.lootSortDesc and " v" or " ^") .. "|r")
        else
            b.fs:SetText(b.label)
        end
    end
    SortRows(rows, ui.lootSortKey, ui.lootSortDesc)
    FauxScrollFrame_Update(ui.lootScroll, #rows, shown, ROW_H)
    local offset = FauxScrollFrame_GetOffset(ui.lootScroll)
    for i = 1, ROWS_MAX do
        local row = ui.lootRows[i]
        local r = i <= shown and rows[offset + i] or nil
        row.data = r
        if r then
            local name, _, q, typ, ilvl, fac = ItemInfo(r.id)
            row.icon:SetTexture(ItemIcon(r.id))
            row.nameFS:SetWidth(nameW)
            row.nameFS:SetText((QUALITY[q] or "|cffa335ee") .. name .. "|r" .. (FACTION_TAG[fac or ""] or "") .. (r.hm and " |cffff8040HM|r" or ""))
            row.typeFS:ClearAllPoints()
            row.typeFS:SetPoint("LEFT", row, "LEFT", 26 + nameW + 8, 0)
            row.typeFS:SetWidth(math.max(40, listW - 26 - nameW - 8 - 96))
            row.typeFS:SetText(typ .. (r.where and ("  |cff888888- " .. r.where .. "|r") or ""))
            row.ilvlFS:SetText(ilvl > 0 and tostring(ilvl) or "")
            local c = r.pct >= 100 and "|cff4cd964" or (r.pct >= 20 and "|cffffffff" or (r.pct >= 5 and "|cffcccccc" or "|cff999999"))
            row.pctFS:SetText(c .. r.pct .. "%|r")
            row:Show()
        else
            row:Hide()
        end
    end
    if #rows == 0 then
        ui.lootEmpty:SetText((entry and entry.note) or "No loot listed here for this mode.")
        ui.lootEmpty:Show()
    else
        ui.lootEmpty:Hide()
    end
end

-- keep the loot list in step with the selected boss / size
local origRefreshDetail = WM.RefreshDetail
function WM:RefreshDetail(...)
    origRefreshDetail(self, ...)
    if self.ui.viewMode == "loot" then self:RefreshLoot() end
end
