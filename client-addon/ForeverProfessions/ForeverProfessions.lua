-- The client's professions pane only shows two professions. This panel lists all of them.

-- "open" is the spell that opens the crafting window. Gathering professions without one
-- are listed with their skill level only.
local PROFESSIONS = {
    { name = "Alchemy",        open = "Alchemy" },
    { name = "Blacksmithing",  open = "Blacksmithing" },
    { name = "Enchanting",     open = "Enchanting" },
    { name = "Engineering",    open = "Engineering" },
    { name = "Leatherworking", open = "Leatherworking" },
    { name = "Tailoring",      open = "Tailoring" },
    { name = "Mining",         open = "Smelting" },
    { name = "Herbalism" },
    { name = "Skinning" },
}

local ROW_HEIGHT = 24
local rows = {}
local refreshPending = false
local macrosReady = false
local macroLimitWarned = false

local frame = CreateFrame("Frame", "ForeverProfessionsFrame", UIParent, "BasicFrameTemplateWithInset")
frame:SetSize(240, 44 + ROW_HEIGHT * #PROFESSIONS)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:SetClampedToScreen(true)
frame:Hide()
frame.TitleText:SetText("Professions")
table.insert(UISpecialFrames, "ForeverProfessionsFrame")

local emptyText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
emptyText:SetPoint("TOP", 0, -40)
emptyText:SetText("No professions learned.")

for i, profession in ipairs(PROFESSIONS) do
    local top = -30 - (i - 1) * ROW_HEIGHT
    local row = {}

    if profession.open then
        -- A secure button is the only way an addon can cast a spell on a click.
        local button = CreateFrame("Button", "ForeverProfessionsButton" .. i, frame, "SecureActionButtonTemplate, UIPanelButtonTemplate")
        button:SetSize(130, 22)
        button:SetPoint("TOPLEFT", 12, top)
        button:SetText(profession.name)
        button:RegisterForClicks("AnyUp", "AnyDown")
        button:SetAttribute("type", "spell")
        button:SetAttribute("spell", profession.open)
        row.button = button
    else
        local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOPLEFT", 16, top - 5)
        label:SetText(profession.name)
        row.label = label
    end

    local level = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    level:SetPoint("TOPRIGHT", -16, top - 5)
    row.level = level

    rows[i] = row
end

local function ReadSkillLevels()
    local levels = {}
    if GetNumSkillLines and GetSkillLineInfo then
        for i = 1, GetNumSkillLines() do
            local name, isHeader, _, rank, _, _, maxRank = GetSkillLineInfo(i)
            if name and not isHeader then
                levels[name] = { rank = rank, maxRank = maxRank }
            end
        end
    end
    return levels
end

local function KnowsSpell(name)
    if C_Spell and C_Spell.GetSpellInfo then
        return C_Spell.GetSpellInfo(name) ~= nil
    end
    return GetSpellInfo and GetSpellInfo(name) ~= nil
end

-- Each macro is only made once per character, so deleting one keeps it deleted. A macro you
-- already have with the same name is left alone.
local function EnsureMacro(profession)
    ForeverProfessionsMacros = ForeverProfessionsMacros or {}
    if ForeverProfessionsMacros[profession.name] then
        return
    end

    if GetMacroIndexByName(profession.name) ~= 0 then
        ForeverProfessionsMacros[profession.name] = true
        return
    end

    local _, characterMacros = GetNumMacros()
    if characterMacros >= (MAX_CHARACTER_MACROS or 18) then
        if not macroLimitWarned then
            macroLimitWarned = true
            print("Forever Professions: no free character macro slots for " .. profession.name .. ".")
        end
        return
    end

    local body = string.format("#showtooltip %s\n/cast %s", profession.open, profession.open)
    if CreateMacro(profession.name, "INV_MISC_QUESTIONMARK", body, true) then
        ForeverProfessionsMacros[profession.name] = true
    end
end

local function Refresh()
    -- Secure buttons and macros can't be changed in combat, so wait until it ends.
    if InCombatLockdown() then
        refreshPending = true
        return
    end
    refreshPending = false

    local levels = ReadSkillLevels()
    local anyKnown = false

    for i, profession in ipairs(PROFESSIONS) do
        local row = rows[i]
        local skill = levels[profession.name]
        local known = skill ~= nil or KnowsSpell(profession.open or profession.name)
        anyKnown = anyKnown or known

        if known and profession.open and macrosReady then
            EnsureMacro(profession)
        end

        local rowElement = row.button or row.label
        rowElement:SetShown(known)
        row.level:SetShown(known)
        if skill then
            row.level:SetFormattedText("%d / %d", skill.rank, skill.maxRank)
        else
            -- A collapsed skill header hides the level, not the profession.
            row.level:SetText("")
        end
    end

    emptyText:SetShown(not anyKnown)
end

frame:SetScript("OnShow", Refresh)
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("SKILL_LINES_CHANGED")
frame:RegisterEvent("SPELLS_CHANGED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:SetScript("OnEvent", function(_, event)
    -- Existing macros aren't available to check any earlier than this.
    if event == "PLAYER_ENTERING_WORLD" then
        macrosReady = true
    end

    if event ~= "PLAYER_REGEN_ENABLED" or refreshPending then
        Refresh()
    end
end)

SLASH_FOREVERPROFESSIONS1 = "/prof"
SlashCmdList.FOREVERPROFESSIONS = function()
    if InCombatLockdown() then
        print("Forever Professions: can't open during combat.")
    else
        frame:SetShown(not frame:IsShown())
    end
end
