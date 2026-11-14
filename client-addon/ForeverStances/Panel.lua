-- /stance: the learned class stances (a button to take or leave each), talent points per class, the per-stance bars
-- switch, and every class, armor and weapon skill (the client's own list hides those its data gives other classes).
local _, ns = ...

local ROW = 26
local MAX_ROWS = 10        -- the real class and up to nine stances

local frame = CreateFrame("Frame", "ForeverStancesPanel", UIParent, "BasicFrameTemplateWithInset")
frame:SetSize(330, 460)
frame:SetPoint("CENTER", -300, 0)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:SetClampedToScreen(true)
frame:Hide()
frame.TitleText:SetText("Class Stances")
table.insert(UISpecialFrames, "ForeverStancesPanel")

local status = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
status:SetPoint("TOPLEFT", 14, -30)
status:SetWidth(300)
status:SetJustifyH("LEFT")

local rows = {}
for i = 1, MAX_ROWS do
    local top = -48 - (i - 1) * ROW
    -- a secure button is the only way an addon can cast a spell on a click
    local cast = CreateFrame("Button", "ForeverStancesPanelCast" .. i, frame, "SecureActionButtonTemplate, UIPanelButtonTemplate")
    cast:SetSize(130, 22)
    cast:SetPoint("TOPLEFT", 12, top)
    cast:RegisterForClicks("AnyUp", "AnyDown")
    local points = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    points:SetPoint("LEFT", cast, "RIGHT", 8, 0)
    local talents = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    talents:SetSize(70, 20)
    talents:SetPoint("TOPRIGHT", -14, top - 1)
    talents:SetText("Talents")
    talents:SetScript("OnClick", function(self) ns.ShowTalents(self.classId) end)
    rows[i] = { cast = cast, points = points, talents = talents }
end

local barsCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
barsCheck:SetSize(24, 24)
local barsLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
barsLabel:SetPoint("LEFT", barsCheck, "RIGHT", 2, 0)
barsLabel:SetText("A separate action bar for each stance")
barsCheck:SetScript("OnClick", function(self) ns.SetSeparateBars(self:GetChecked() and true or false) end)

local skillsTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
skillsTitle:SetText("Class, armor and weapon skills")
local skillsScroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
local skillsText = CreateFrame("Frame", nil, skillsScroll)
skillsText:SetSize(280, 10)
skillsScroll:SetScrollChild(skillsText)
local skillsString = skillsText:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
skillsString:SetPoint("TOPLEFT")
skillsString:SetWidth(280)
skillsString:SetJustifyH("LEFT")

local CATEGORY = { [6] = "Weapon", [7] = "Class", [8] = "Armor" }

local function StanceName(classId)
    local spell = ns.StanceSpell(classId)
    local name = spell and C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(spell)
    return name or (ns.ClassName(classId) .. " Stance")
end

local function DrawSkills(top)
    skillsTitle:ClearAllPoints()
    skillsTitle:SetPoint("TOPLEFT", 14, top)
    skillsScroll:ClearAllPoints()
    skillsScroll:SetPoint("TOPLEFT", 14, top - 18)
    skillsScroll:SetPoint("BOTTOMRIGHT", -32, 12)
    local lines, last = {}, nil
    for _, skill in ipairs(ns.skills) do
        if skill.category ~= last then
            last = skill.category
            table.insert(lines, "|cffffd100" .. (CATEGORY[skill.category] or "Other") .. "|r")
        end
        local value = skill.max > 1 and string.format("  %d/%d", skill.value, skill.max) or ""
        table.insert(lines, "  " .. skill.name .. value)
    end
    skillsString:SetText(#lines > 0 and table.concat(lines, "\n") or "No skills reported by the server yet.")
    skillsText:SetHeight(skillsString:GetStringHeight() + 4)
end

local function Draw()
    if not frame:IsShown() then return end
    local state = ns.state
    if not state.known then
        status:SetText("Waiting for the server... (/stance ping to test the link)")
    elseif #state.learned == 0 then
        status:SetText("No class stances learned yet. Class trainers of other classes sell them from level 10.")
    else
        local active = ns.auraStance or state.active
        status:SetText(active ~= 0 and ("Fighting as a " .. ns.ClassName(active) .. ". Click its stance to return.")
            or ("Fighting as your own class (" .. ns.ClassName(state.realClass) .. ")."))
    end

    local list = {}
    if state.known and #state.learned > 0 then
        table.insert(list, 0)          -- the real class: leaves the active stance
        for _, classId in ipairs(state.learned) do table.insert(list, classId) end
    end
    local active = ns.auraStance or state.active or 0
    local combat = InCombatLockdown()
    for i, row in ipairs(rows) do
        local classId = list[i]
        if classId == nil then
            if not combat then row.cast:Hide() end
            row.points:SetText("")
            row.talents:Hide()
        else
            if not combat then
                if classId == 0 then
                    row.cast:SetText(ns.ClassName(state.realClass) .. (active == 0 and " (active)" or ""))
                    if active ~= 0 then
                        row.cast:SetAttribute("type", "macro")
                        row.cast:SetAttribute("macrotext", "/cancelaura " .. StanceName(active))
                    else
                        row.cast:SetAttribute("type", nil)
                    end
                else
                    row.cast:SetText(StanceName(classId) .. (classId == active and " (active)" or ""))
                    row.cast:SetAttribute("type", "spell")
                    row.cast:SetAttribute("spell", ns.StanceSpell(classId))
                end
                row.cast:Show()
            end
            local p = classId ~= 0 and state.points[classId]
            row.points:SetText(p and string.format("%d/%d points", p.total - p.spent, p.total) or "")
            row.talents.classId = classId
            row.talents:SetShown(classId ~= 0)
        end
    end

    local top = -48 - math.max(#list, 1) * ROW - 6
    barsCheck:ClearAllPoints()
    barsCheck:SetPoint("TOPLEFT", 10, top)
    barsCheck:SetChecked(ns.db and ns.db.separateBars)
    DrawSkills(top - 30)
end

function ns.TogglePanel()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
        ns.Send(ns.state.known and "SKILLS" or "HELLO")
        Draw()
    end
end

ns.On("STATE", function() ns.AfterCombat("panel", Draw) end)
ns.On("SKILLS", Draw)
ns.On("STANCE_CHANGED", function() ns.AfterCombat("panel", Draw) end)
