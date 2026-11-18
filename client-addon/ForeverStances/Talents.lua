-- The talent window for stance classes: the three trees of a learned stance class side by side, WoW Forever's trait trees as
-- the client's own talent window shows them (Data/Talents.lua, the same trees the server checks picks against). Picks go to
-- the server, which checks them, keeps them and sends the trees back.
local _, ns = ...

local BUTTON, GAP = 34, 10
local COLUMNS, TIERS = 4, 7
local TREE_WIDTH = COLUMNS * (BUTTON + GAP) + GAP
local TREE_HEIGHT = TIERS * (BUTTON + GAP) + GAP

local frame = CreateFrame("Frame", "ForeverStancesTalentFrame", UIParent, "BasicFrameTemplateWithInset")
local TAB_SIZE, TREE_TOP = 28, -96
frame:SetSize(3 * TREE_WIDTH + 40, TREE_HEIGHT - TREE_TOP + 38)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:SetClampedToScreen(true)
frame:SetFrameStrata("HIGH")
frame:Hide()
frame.TitleText:SetText("Stance Talents")
table.insert(UISpecialFrames, "ForeverStancesTalentFrame")

-- the window's size: one scale for the whole account (ForeverStancesAccountDB.talentScale), set with the corner grip or /stance scale
local DEFAULT_SCALE, MIN_SCALE, MAX_SCALE = 1.25, 0.6, 2.0

function ns.SetTalentScale(scale)
    scale = math.max(MIN_SCALE, math.min(MAX_SCALE, scale or DEFAULT_SCALE))
    -- keep the top left corner where it is on screen
    local left, top = frame:GetLeft(), frame:GetTop()
    local old = frame:GetScale()
    frame:SetScale(scale)
    if left and top then
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left * old / scale, top * old / scale)
    end
    if ns.accountDb then ns.accountDb.talentScale = scale end
    return scale
end

local grip = CreateFrame("Button", nil, frame)
grip:SetSize(16, 16)
grip:SetPoint("BOTTOMRIGHT", -4, 4)
grip:SetFrameLevel(frame:GetFrameLevel() + 20)
grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
grip:SetScript("OnMouseDown", function(self)
    local x = GetCursorPosition() / UIParent:GetEffectiveScale()
    local left = frame:GetLeft() * frame:GetScale()
    self.startWidth = math.max(x - left, 50)
    self.startScale = frame:GetScale()
    self.left = left
    self:SetScript("OnUpdate", function()
        local cx = GetCursorPosition() / UIParent:GetEffectiveScale()
        local width = math.max(cx - self.left, 50)
        local scale = math.max(MIN_SCALE, math.min(MAX_SCALE, self.startScale * width / self.startWidth))
        frame:SetScale(scale)
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", self.left / scale, self.top / scale)
    end)
    self.top = frame:GetTop() * frame:GetScale()
end)
grip:SetScript("OnMouseUp", function(self)
    self:SetScript("OnUpdate", nil)
    if ns.accountDb then ns.accountDb.talentScale = frame:GetScale() end
end)

ns.On("LOADED", function()
    frame:SetScale(ns.accountDb.talentScale or DEFAULT_SCALE)
end)

local pointsText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
pointsText:SetPoint("BOTTOMLEFT", 16, 14)

local noteText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
noteText:SetPoint("BOTTOM", 0, 16)

local emptyText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
emptyText:SetPoint("CENTER")
emptyText:SetText("Learn another class's stance from its trainer to get its talents.")

local selected                -- the class shown
local classButtons = {}
local trees = {}               -- [1..3] = { frame, title, buttons = { [talentId] = button }, lines = {} }

local function Ranks(classId)
    return (ns.talents and ns.talents[classId]) or {}
end

local function SpentInTab(classId, tab)
    local ranks, spent = Ranks(classId), 0
    for _, talent in ipairs(tab.talents) do
        spent = spent + (ranks[talent.id] or 0)
    end
    return spent
end

local function PointsLeft(classId)
    local p = ns.state.points[classId]
    return p and (p.total - p.spent) or 0
end

-- may the next rank be taken (the server checks again)
local function CanLearn(classId, tab, talent)
    local ranks = Ranks(classId)
    local rank = ranks[talent.id] or 0
    if rank >= talent.max or PointsLeft(classId) <= 0 then return false end
    if SpentInTab(classId, tab) < talent.need then return false end
    for _, prereq in ipairs(talent.prereqs) do
        if (ranks[prereq[1]] or 0) < prereq[2] then return false end
    end
    return true
end

local function SpellText(spell)
    if C_Spell and C_Spell.GetSpellDescription then
        local ok, text = pcall(C_Spell.GetSpellDescription, spell)
        if ok and text and text ~= "" then return text end
    end
    if GetSpellDescription then
        local ok, text = pcall(GetSpellDescription, spell)
        if ok then return text end
    end
end

local function SpellIcon(spell)
    if C_Spell and C_Spell.GetSpellTexture then return C_Spell.GetSpellTexture(spell) end
    if GetSpellTexture then return GetSpellTexture(spell) end
end

local function SpellName(spell)
    if C_Spell and C_Spell.GetSpellName then return C_Spell.GetSpellName(spell) end
    if GetSpellInfo then return (GetSpellInfo(spell)) end
end

-- the text of a talent at a rank, scaled as the client's own talent window scales it (the rank spells are unscaled templates)
local function TraitText(entry, rank)
    if entry and entry > 0 and C_Traits and C_Traits.GetTraitDescription then
        local ok, text = pcall(C_Traits.GetTraitDescription, entry, rank)
        if ok and type(text) == "string" and text ~= "" then return text end
    end
end

-- the talent's text at a rank: the client's scaled trait text, else the rank spell's own (talents with no trait)
local function RankText(talent, rank)
    return TraitText(talent.entry, rank) or SpellText(talent.spell)
end

-- the client loads a spell's data the first time it is asked for: a text that comes back empty is asked for and the tooltip
-- drawn again when it arrives (SPELL_DATA_LOAD_RESULT), so the first hover need not be repeated
local waitingButton

local function ShowTooltip(button)
    local talent, classId = button.talent, selected
    local rank = Ranks(classId)[talent.id] or 0
    GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
    GameTooltip:SetText(SpellName(talent.spell) or "?", 1, 1, 1)
    GameTooltip:AddLine(string.format("Rank %d/%d", rank, talent.max), 1, 1, 1)
    local text = RankText(talent, math.max(rank, 1))
    if text then
        GameTooltip:AddLine(text, 1, 0.82, 0, true)
        if waitingButton == button then waitingButton = nil end
    elseif waitingButton ~= button then
        waitingButton = button
        if C_Spell and C_Spell.RequestLoadSpellData then pcall(C_Spell.RequestLoadSpellData, talent.spell) end
        -- and once more shortly in case the client sends no event
        C_Timer.After(0.3, function()
            if waitingButton == button and GameTooltip:IsOwned(button) then ShowTooltip(button) end
        end)
    end
    if rank > 0 and rank < talent.max then
        local nextText = RankText(talent, rank + 1)
        if nextText then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Next rank:", 1, 1, 1)
            GameTooltip:AddLine(nextText, 1, 0.82, 0, true)
        end
    end
    if SpentInTab(classId, button.tab) < talent.need then
        GameTooltip:AddLine(string.format("Requires %d points in %s", talent.need, button.tab.name), 1, 0.1, 0.1)
    end
    for _, prereq in ipairs(talent.prereqs) do
        if (Ranks(classId)[prereq[1]] or 0) < prereq[2] then
            local other = button.tree.buttons[prereq[1]]
            local name = other and SpellName(other.talent.spell) or "another talent"
            GameTooltip:AddLine(string.format("Requires %d point%s in %s", prereq[2], prereq[2] > 1 and "s" or "", name), 1, 0.1, 0.1)
        end
    end
    if CanLearn(classId, button.tab, talent) then
        GameTooltip:AddLine("Click to learn", 0, 1, 0)
    end
    GameTooltip:Show()
end

local function MakeTree(index)
    local tree = CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
    tree:SetSize(TREE_WIDTH, TREE_HEIGHT)
    tree:SetPoint("TOPLEFT", 14 + (index - 1) * (TREE_WIDTH + 6), TREE_TOP)
    -- the header: the spec's icon (its name and points in the tooltip) and its name, cut short to the tree's width
    local icon = ns.IconTab(tree, 20)
    icon:SetPoint("BOTTOMLEFT", tree, "TOPLEFT", 4, 4)
    local title = tree:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", icon, "RIGHT", 6, 0)
    title:SetPoint("RIGHT", tree, "RIGHT", -4, 0)
    title:SetJustifyH("LEFT")
    title:SetWordWrap(false)
    trees[index] = { frame = tree, icon = icon, title = title, buttons = {}, lines = {}, pool = {} }
    return trees[index]
end

local function TalentButton(tree, n)
    local button = tree.pool[n]
    if button then return button end
    button = CreateFrame("Button", nil, tree.frame)
    button:SetSize(BUTTON, BUTTON)
    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetAllPoints()
    button.border = button:CreateTexture(nil, "OVERLAY")
    button.border:SetPoint("TOPLEFT", -2, 2)
    button.border:SetPoint("BOTTOMRIGHT", 2, -2)
    button.border:SetColorTexture(1, 1, 1, 0.15)
    button.border:SetDrawLayer("BACKGROUND")
    button.rank = button:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
    button.rank:SetPoint("BOTTOMRIGHT", 4, -4)
    button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    button:SetScript("OnEnter", ShowTooltip)
    button:SetScript("OnLeave", function()
        waitingButton = nil
        GameTooltip:Hide()
    end)
    button:SetScript("OnClick", function(self)
        if InCombatLockdown() then
            UIErrorsFrame:AddMessage("Not in combat.", 1, 0.1, 0.1)
        elseif CanLearn(selected, self.tab, self.talent) then
            ns.Send(string.format("LEARN %d %d", selected, self.talent.id))
        end
    end)
    tree.pool[n] = button
    return button
end

for i = 1, 3 do MakeTree(i) end

local resetButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
resetButton:SetSize(120, 22)
resetButton:SetPoint("BOTTOMRIGHT", -24, 10)
resetButton:SetText("Reset talents")

StaticPopupDialogs.FOREVER_STANCES_RESET = {
    text = "Reset your %s talents? The points are given back.",
    button1 = YES, button2 = NO,
    OnAccept = function(_, classId) ns.Send(string.format("RESET %d", classId)) end,
    timeout = 0, whileDead = true, hideOnEscape = true,
}
resetButton:SetScript("OnClick", function()
    if selected then
        local dialog = StaticPopup_Show("FOREVER_STANCES_RESET", ns.ClassName(selected))
        if dialog then dialog.data = selected end
    end
end)

local function Draw()
    if not frame:IsShown() then return end
    local learned = ns.state.learned
    for i, b in ipairs(classButtons) do b:Hide() end
    for i, classId in ipairs(learned) do
        local b = classButtons[i]
        if not b then
            b = ns.IconTab(frame, TAB_SIZE)
            b:SetPoint("TOPLEFT", 16 + (i - 1) * (TAB_SIZE + 6), -32)
            b:SetScript("OnClick", function(self)
                selected = self.classId
                if not (ns.talents and ns.talents[selected]) then ns.Send("TALENTS " .. selected) end
                Draw()
            end)
            classButtons[i] = b
        end
        b.classId = classId
        b:Set(ns.ClassIcon(classId), ns.ClassName(classId), "Talents", classId == selected)
        b:Show()
    end

    frame.TitleText:SetText(selected and ("Stance Talents: " .. ns.ClassName(selected)) or "Stance Talents")
    local data = selected and ns.Talents[selected]
    emptyText:SetShown(not data)
    resetButton:SetShown(data ~= nil)
    for _, tree in ipairs(trees) do tree.frame:SetShown(data ~= nil) end
    if not data then
        pointsText:SetText("")
        noteText:SetText("")
        return
    end

    local ranks = Ranks(selected)
    for index, tab in ipairs(data) do
        local tree = trees[index]
        local spent = SpentInTab(selected, tab)
        tree.title:SetText(string.format("%s (%d)", tab.name, spent))
        tree.icon:Set(tab.icon, tab.name, string.format("%d point%s spent", spent, spent == 1 and "" or "s"))
        wipe(tree.buttons)
        for _, b in ipairs(tree.pool) do b:Hide() end
        for _, line in ipairs(tree.lines) do line:Hide() end
        for n, talent in ipairs(tab.talents) do
            local button = TalentButton(tree, n)
            button.talent, button.tab, button.tree = talent, tab, tree
            button:ClearAllPoints()
            button:SetPoint("TOPLEFT", GAP + talent.column * (BUTTON + GAP), -GAP - talent.tier * (BUTTON + GAP))
            button.icon:SetTexture(SpellIcon(talent.spell) or 134400)
            local rank = ranks[talent.id] or 0
            button.rank:SetText(string.format("%d/%d", rank, talent.max))
            local can = CanLearn(selected, tab, talent)
            local maxed = rank >= talent.max
            button.icon:SetDesaturated(rank == 0 and not can)
            if maxed then
                button.rank:SetTextColor(1, 0.82, 0)
            elseif rank > 0 or can then
                button.rank:SetTextColor(0.1, 1, 0.1)
            else
                button.rank:SetTextColor(0.5, 0.5, 0.5)
            end
            button:Show()
            tree.buttons[talent.id] = button
        end
        -- prerequisite lines
        local n = 0
        if tree.frame.CreateLine then
            for _, talent in ipairs(tab.talents) do
                for _, prereq in ipairs(talent.prereqs) do
                    local from, to = tree.buttons[prereq[1]], tree.buttons[talent.id]
                    if from and to then
                        n = n + 1
                        local line = tree.lines[n]
                        if not line then
                            line = tree.frame:CreateLine(nil, "BACKGROUND")
                            line:SetThickness(3)
                            tree.lines[n] = line
                        end
                        line:SetStartPoint("CENTER", from)
                        line:SetEndPoint("CENTER", to)
                        if (ranks[prereq[1]] or 0) >= prereq[2] then
                            line:SetColorTexture(1, 0.82, 0, 0.8)
                        else
                            line:SetColorTexture(0.5, 0.5, 0.5, 0.6)
                        end
                        line:Show()
                    end
                end
            end
        end
    end

    local p = ns.state.points[selected] or { total = 0, spent = 0 }
    pointsText:SetText(string.format("%s talent points: %d of %d left", ns.ClassName(selected), p.total - p.spent, p.total))
    if ns.state.alwaysActive then
        noteText:SetText("Always active")
    else
        noteText:SetText(string.format("Active in %s Stance", ns.ClassName(selected)))
    end
end

function ns.ShowTalents(classId)
    if not ns.state.known then ns.Send("HELLO") end
    selected = classId or selected or ns.state.learned[1]
    frame:Show()
    if selected then ns.Send("TALENTS " .. selected) end
    Draw()
end

function ns.ToggleTalents()
    if frame:IsShown() then frame:Hide() else ns.ShowTalents() end
end

local spellData = CreateFrame("Frame")
spellData:RegisterEvent("SPELL_DATA_LOAD_RESULT")
spellData:SetScript("OnEvent", function(_, _, spellId)
    local button = waitingButton
    if button and button.talent and button.talent.spell == spellId and GameTooltip:IsOwned(button) then
        ShowTooltip(button)
    end
end)

ns.On("TALENTS", Draw)
ns.On("STATE", function()
    if selected and not tContains(ns.state.learned, selected) then selected = nil end
    Draw()
end)

-- The talent key (N) and the talent micro button: in a class stance they toggle that class's trees (Intercept.lua)
local CLIENT_FRAMES = { "PlayerTalentFrame", "TalentFrame", "ClassTalentFrame", "PlayerSpellsFrame" }

ns.Intercept{
    name = "Talent", binding = "TOGGLETALENTS", microButtons = { "TalentMicroButton", "PlayerSpellsMicroButton" },
    title = "Stance Talents", what = "talents",
    enabled = function(active) return ns.Talents[active] ~= nil end,
    toggle = function(active)
        if frame:IsShown() and selected == active then
            frame:Hide()
        else
            for _, name in ipairs(CLIENT_FRAMES) do
                local f = _G[name]
                if f and f:IsShown() then HideUIPanel(f) end
            end
            ns.ShowTalents(active)
        end
    end,
}

-- taking a class stance with our window open shows the new class's trees; leaving the stance closes it
ns.On("STANCE_CHANGED", function(active)
    if active ~= 0 then
        if frame:IsShown() then ns.ShowTalents(active) end
    elseif frame:IsShown() then
        frame:Hide()
    end
end)

-- Prototype: a stance class's talents in the client's own talent window. The server gives every learned stance class a trait
-- config of its spec (id 2130000000 + class, ClassStance::SyncTraitConfigs) and learns a commit of one by the stance rules.
-- /stance tree <class id> opens it in the talent window, /stance tree <class id> generic in the generic trait frame.
local TRAIT_CONFIG_BASE = 2130000000
-- each class's trait tree (SkillLineXTraitTree): the client fills a config's treeIDs from the player's own class
local CLASS_TREES = { [1] = 1117, [2] = 1100, [3] = 1091, [4] = 1111, [5] = 1114, [7] = 1082, [8] = 1112, [9] = 1116, [11] = 1089 }

local function Diagnose(configID, treeID)
    local ok, nodes = pcall(C_Traits.GetTreeNodes, treeID)
    if not ok or not nodes then ns.Print("tree " .. treeID .. ": no nodes (" .. tostring(nodes) .. ")") return end
    local visible, ranked, spent = 0, 0, 0
    for _, nodeID in ipairs(nodes) do
        local okInfo, info = pcall(C_Traits.GetNodeInfo, configID, nodeID)
        if okInfo and info then
            if info.isVisible then visible = visible + 1 end
            if (info.currentRank or 0) > 0 then ranked = ranked + 1 spent = spent + info.currentRank end
        end
    end
    local okCur, currencies = pcall(C_Traits.GetTreeCurrencyInfo, configID, treeID, false)
    local points = okCur and currencies and currencies[1]
    ns.Print(string.format("tree %d: %d nodes, %d visible, %d with ranks (%d spent); points %s/%s", treeID, #nodes, visible, ranked, spent,
        points and tostring(points.quantity) or "?", points and tostring(points.maxQuantity) or "?"))
end

function ns.ShowTraitTree(classId, generic)
    local configID = TRAIT_CONFIG_BASE + classId
    local ok, info = pcall(C_Traits.GetConfigInfo, configID)
    if not ok or not info then
        ns.Print(string.format("no trait config %d for %s (%s).", configID, ns.ClassName(classId), tostring(info)))
        return
    end
    ns.Print(string.format("config %d \"%s\": type %s, trees %s", configID, tostring(info.name), tostring(info.type),
        table.concat(info.treeIDs or {}, ",")))
    if CLASS_TREES[classId] then Diagnose(configID, CLASS_TREES[classId]) end
    if InCombatLockdown() then ns.Print("not in combat.") return end

    local shown, err
    if generic then
        shown, err = pcall(function()
            if GenericTraitUI_LoadUI then GenericTraitUI_LoadUI() else C_AddOns.LoadAddOn("Blizzard_GenericTraitUI") end
            GenericTraitFrame:SetConfigID(configID, true)
            GenericTraitFrame:SetTalentTreeID(CLASS_TREES[classId], true)
            ShowUIPanel(GenericTraitFrame)
        end)
    else
        shown, err = pcall(function()
            C_AddOns.LoadAddOn("Blizzard_PlayerSpells")
            if not PlayerSpellsFrame:IsShown() then ShowUIPanel(PlayerSpellsFrame) end
            PlayerSpellsFrame:SetTab(PlayerSpellsFrame.talentTabID)
            PlayerSpellsFrame.TalentsFrame:SetConfigID(configID, true)
            PlayerSpellsFrame.TalentsFrame:SetTalentTreeID(CLASS_TREES[classId], true)
        end)
    end
    if not shown then ns.Print("could not open it: " .. tostring(err)) end
end
