-- The stance spellbook: in a class stance the spellbook key (P) and micro button show the spells you have learned for that
-- class, a tab per skill line (Fire, Frost, Arcane...), the highest rank of each unless "All ranks" is ticked. Click to cast,
-- drag to an action bar. The server sends the list (SPELLS), so it matches what the server lets you cast.
local _, ns = ...

local PER_PAGE, COLUMNS = 14, 2
local ENTRY_W, ENTRY_H = 200, 44
local CLIENT_FRAMES = { "SpellBookFrame", "PlayerSpellsFrame" }

local frame = CreateFrame("Frame", "ForeverStancesSpellbook", UIParent, "BasicFrameTemplateWithInset")
frame:SetSize(COLUMNS * ENTRY_W + 40, (PER_PAGE / COLUMNS) * ENTRY_H + 120)
frame:SetPoint("CENTER", -200, 0)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:SetClampedToScreen(true)
frame:SetFrameStrata("HIGH")
frame:Hide()
table.insert(UISpecialFrames, "ForeverStancesSpellbook")

local shown            -- the class shown
local tab = 1          -- the skill line tab
local page = 1
local tabButtons = {}

local pageText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
pageText:SetPoint("BOTTOM", 0, 16)

local emptyText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
emptyText:SetPoint("CENTER")

local allRanks = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
allRanks:SetSize(22, 22)
allRanks:SetPoint("BOTTOMLEFT", 12, 10)
local allRanksLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
allRanksLabel:SetPoint("LEFT", allRanks, "RIGHT", 2, 0)
allRanksLabel:SetText("All ranks")

local prev = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
prev:SetSize(60, 22)
prev:SetPoint("BOTTOMRIGHT", -80, 10)
prev:SetText("Prev")
local nextButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
nextButton:SetSize(60, 22)
nextButton:SetPoint("BOTTOMRIGHT", -14, 10)
nextButton:SetText("Next")

local function Subtext(id)
    if C_Spell and C_Spell.GetSpellSubtext then
        local ok, text = pcall(C_Spell.GetSpellSubtext, id)
        if ok then return text end
    end
    if GetSpellSubtext then return GetSpellSubtext(id) end
end

local function SpellName(id)
    if C_Spell and C_Spell.GetSpellName then return C_Spell.GetSpellName(id) end
    return (GetSpellInfo(id))
end

local function SpellIcon(id)
    if C_Spell and C_Spell.GetSpellTexture then return C_Spell.GetSpellTexture(id) end
    return GetSpellTexture(id)
end

local function IsPassive(id)
    if C_Spell and C_Spell.IsSpellPassive then
        local ok, passive = pcall(C_Spell.IsSpellPassive, id)
        if ok then return passive end
    end
    return IsPassiveSpell and IsPassiveSpell(id) or false
end

local function RankNumber(id)
    local text = Subtext(id)
    return text and tonumber(text:match("(%d+)")) or 0
end

-- the client spellbook's General tab (Attack, Shoot, racials...): the same for every class, so shown in each stance book
local GENERAL = -1
local function GeneralSpells()
    local list = {}
    if C_SpellBook and C_SpellBook.GetSpellBookSkillLineInfo and C_SpellBook.GetSpellBookItemInfo then
        local ok, info = pcall(C_SpellBook.GetSpellBookSkillLineInfo, 1)
        if ok and info and info.itemIndexOffset then
            local bank = Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player or 0
            local spellType = Enum.SpellBookItemType and Enum.SpellBookItemType.Spell or 1
            for i = info.itemIndexOffset + 1, info.itemIndexOffset + (info.numSpellBookItems or 0) do
                local okItem, item = pcall(C_SpellBook.GetSpellBookItemInfo, i, bank)
                if okItem and item and item.spellID and item.itemType == spellType then
                    table.insert(list, item.spellID)
                end
            end
            return list
        end
    end
    if GetSpellTabInfo and GetSpellBookItemInfo then
        local _, _, offset, count = GetSpellTabInfo(1)
        for i = (offset or 0) + 1, (offset or 0) + (count or 0) do
            local itemType, id = GetSpellBookItemInfo(i, BOOKTYPE_SPELL or "spell")
            if itemType == "SPELL" and id then table.insert(list, id) end
        end
    end
    return list
end

-- the tabs (skill lines) and their spells, sorted by name, the highest rank only unless all ranks are wanted
local function Book()
    local data = ns.spellbooks and ns.spellbooks[shown]
    if not data then return nil end
    local tabs, byTab = {}, {}
    local spells = {}
    for _, id in ipairs(GeneralSpells()) do table.insert(spells, { id = id, skill = GENERAL }) end
    for _, spell in ipairs(data.spells) do table.insert(spells, spell) end
    for _, spell in ipairs(spells) do
        local name = SpellName(spell.id)
        if name then
            local key = spell.skill
            if not byTab[key] then
                byTab[key] = {}
                table.insert(tabs, { skill = key, name = key == GENERAL and "General" or data.skills[key] or "Other" })
            end
            table.insert(byTab[key], { id = spell.id, name = name, rank = RankNumber(spell.id) })
        end
    end
    -- General first, then the skill lines, then spells of no class skill line
    local function order(t) return t.skill == GENERAL and 0 or (t.skill == 0 and 2 or 1) end
    table.sort(tabs, function(a, b)
        if order(a) ~= order(b) then return order(a) < order(b) end
        return a.name < b.name
    end)
    for _, t in ipairs(tabs) do
        local list = byTab[t.skill]
        if not (ns.db and ns.db.allRanks) then
            local best = {}
            for _, s in ipairs(list) do
                if not best[s.name] or s.rank > best[s.name].rank then best[s.name] = s end
            end
            list = {}
            for _, s in pairs(best) do table.insert(list, s) end
        end
        table.sort(list, function(a, b)
            local pa, pb = IsPassive(a.id), IsPassive(b.id)
            if pa ~= pb then return pb end
            if a.name ~= b.name then return a.name < b.name end
            return a.rank < b.rank
        end)
        t.spells = list
    end
    return tabs
end

local entries = {}
for i = 1, PER_PAGE do
    local column = (i - 1) % COLUMNS
    local row = math.floor((i - 1) / COLUMNS)
    -- a secure button: clicking casts the spell
    local b = CreateFrame("Button", "ForeverStancesSpellbookEntry" .. i, frame, "SecureActionButtonTemplate")
    b:SetSize(36, 36)
    b:SetPoint("TOPLEFT", 20 + column * ENTRY_W, -64 - row * ENTRY_H)
    -- cast on release, as the client's spellbook does: a press that turns into a drag does not cast
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    b:RegisterForDrag("LeftButton")
    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetAllPoints()
    b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    b.name = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    b.name:SetPoint("TOPLEFT", b, "TOPRIGHT", 6, -2)
    b.name:SetWidth(ENTRY_W - 50)
    b.name:SetJustifyH("LEFT")
    b.sub = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    b.sub:SetPoint("TOPLEFT", b.name, "BOTTOMLEFT", 0, -2)
    b:SetScript("OnEnter", function(self)
        if not self.spell then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetSpellByID(self.spell)
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", GameTooltip_Hide)
    b:SetScript("OnDragStart", function(self)
        if self.spell and not InCombatLockdown() then
            if C_Spell and C_Spell.PickupSpell then C_Spell.PickupSpell(self.spell) else PickupSpell(self.spell) end
        end
    end)
    entries[i] = b
end

local function Draw()
    if not frame:IsShown() or not shown then return end
    frame.TitleText:SetText(ns.ClassName(shown) .. " Spells")
    allRanks:SetChecked(ns.db and ns.db.allRanks)
    local tabs = Book()
    local combat = InCombatLockdown()

    for _, b in ipairs(tabButtons) do b:Hide() end
    if not tabs or #tabs == 0 then
        emptyText:SetText(tabs and ("No " .. ns.ClassName(shown) .. " spells learned yet. Visit a " .. ns.ClassName(shown) .. " trainer.")
            or "Loading...")
        emptyText:Show()
        pageText:SetText("")
        if not combat then for _, e in ipairs(entries) do e:Hide() end end
        return
    end
    emptyText:Hide()
    tab = math.min(tab, #tabs)

    for i, t in ipairs(tabs) do
        local b = tabButtons[i]
        if not b then
            b = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
            b:SetSize(96, 22)
            b:SetPoint("TOPLEFT", 14 + (i - 1) * 100, -30)
            b:SetScript("OnClick", function(self)
                if InCombatLockdown() then return end
                tab, page = self.index, 1
                Draw()
            end)
            tabButtons[i] = b
        end
        b.index = i
        b:SetText(t.name)
        b:Show()
        if i == tab then b:LockHighlight() else b:UnlockHighlight() end
    end

    local spells = tabs[tab].spells
    local pages = math.max(1, math.ceil(#spells / PER_PAGE))
    page = math.min(page, pages)
    pageText:SetText(string.format("Page %d of %d", page, pages))
    prev:SetEnabled(page > 1 and not combat)
    nextButton:SetEnabled(page < pages and not combat)

    if combat then return end      -- secure buttons keep their spells until combat ends
    for i, b in ipairs(entries) do
        local spell = spells[(page - 1) * PER_PAGE + i]
        if spell then
            local passive = IsPassive(spell.id)
            b.spell = spell.id
            b.icon:SetTexture(SpellIcon(spell.id) or 134400)
            b.icon:SetDesaturated(passive)
            b.name:SetText(spell.name)
            local sub = Subtext(spell.id) or ""
            b.sub:SetText(passive and (sub ~= "" and (sub .. ", Passive") or "Passive") or sub)
            b:SetAttribute("type", (not passive) and "spell" or nil)   -- a passive spell is shown, not cast
            b:SetAttribute("spell", spell.id)
            b:Show()
        else
            b.spell = nil
            b:SetAttribute("type", nil)
            b:Hide()
        end
    end
end

prev:SetScript("OnClick", function() page = page - 1 Draw() end)
nextButton:SetScript("OnClick", function() page = page + 1 Draw() end)
allRanks:SetScript("OnClick", function(self)
    if ns.db then ns.db.allRanks = self:GetChecked() and true or false end
    page = 1
    Draw()
end)

function ns.ShowSpellbook(classId)
    if InCombatLockdown() and not frame:IsShown() then
        UIErrorsFrame:AddMessage("The stance spellbook opens out of combat.", 1, 0.1, 0.1)
        return
    end
    if shown ~= classId then tab, page = 1, 1 end
    shown = classId
    frame:Show()
    ns.Send("SPELLS " .. classId)
    Draw()
end

ns.Intercept{
    name = "Spellbook", binding = "TOGGLESPELLBOOK", microButtons = { "SpellbookMicroButton" },
    title = "Stance Spellbook", what = "spells",
    toggle = function(active)
        if frame:IsShown() and shown == active then
            frame:Hide()
        else
            for _, name in ipairs(CLIENT_FRAMES) do
                local f = _G[name]
                if f and f:IsShown() then HideUIPanel(f) end
            end
            ns.ShowSpellbook(active)
        end
    end,
}

ns.On("SPELLS", function(classId) if classId == shown then Draw() end end)

-- a spell learned at a trainer while the book is open: ask again (once, shortly after)
local pending = false
local events = CreateFrame("Frame")
events:RegisterEvent("LEARNED_SPELL_IN_TAB")
events:RegisterEvent("SPELLS_CHANGED")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:SetScript("OnEvent", function(_, event)
    if not frame:IsShown() or not shown then return end
    if event == "PLAYER_REGEN_ENABLED" then Draw() return end
    if pending then return end
    pending = true
    C_Timer.After(0.5, function()
        pending = false
        if frame:IsShown() and shown then ns.Send("SPELLS " .. shown) end
    end)
end)

ns.On("STANCE_CHANGED", function(active)
    if not frame:IsShown() then return end
    if active ~= 0 then ns.ShowSpellbook(active) else frame:Hide() end
end)
