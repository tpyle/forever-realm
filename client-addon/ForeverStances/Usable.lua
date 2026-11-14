-- Greys out action buttons whose spell belongs to a learned class other than the one you fight as (the server refuses
-- them: "Requires Mage Stance." / "Leave Mage Stance first."). Visual only: an addon cannot stop a secure button.
local _, ns = ...

local BAR_PREFIXES = { "ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton", "MultiBarRightButton",
                       "MultiBarLeftButton", "MultiBar5Button", "MultiBar6Button", "MultiBar7Button" }

-- the class whose abilities work now, nil before the server has told us the real class
local function CurrentClass()
    if not ns.state.realClass then return nil end
    local active = ns.auraStance or ns.state.active or 0
    return active ~= 0 and active or ns.state.realClass
end

local function IsLearnedClass(classId)
    if classId == ns.state.realClass then return true end
    for _, c in ipairs(ns.state.learned) do
        if c == classId then return true end
    end
    return false
end

-- true when the action is a spell of another class the player knows (only those are refused; spells of classes with no
-- learned stance, such as item spells, are not)
local function IsBlocked(action)
    local current = CurrentClass()
    if not current or #ns.state.learned == 0 or not action then return false end
    local ok, actionType, id = pcall(GetActionInfo, action)
    if not ok or actionType ~= "spell" or not id then return false end
    if issecretvalue and issecretvalue(id) then return false end
    local spellClass = ns.SpellClasses[id]
    return spellClass ~= nil and spellClass ~= current and IsLearnedClass(spellClass)
end

local function Tint(button)
    local icon = button.icon or button.Icon or (button.GetName and _G[button:GetName() .. "Icon"])
    if not icon then return end
    local action = button.action or (button.GetAttribute and button:GetAttribute("action"))
    if IsBlocked(action) then
        icon:SetVertexColor(0.35, 0.35, 0.35)
        if icon.SetDesaturated then icon:SetDesaturated(true) end
        button.foreverStancesTinted = true
    elseif button.foreverStancesTinted then
        button.foreverStancesTinted = nil
        if icon.SetDesaturated then icon:SetDesaturated(false) end
        if button.UpdateUsable then
            pcall(button.UpdateUsable, button)
        else
            icon:SetVertexColor(1, 1, 1)
        end
    end
end

local buttons = {}
local function CollectButtons()
    for _, prefix in ipairs(BAR_PREFIXES) do
        for i = 1, 12 do
            local button = _G[prefix .. i]
            if button and not buttons[button] then
                buttons[button] = true
                -- the client repaints usability often; tint again after it
                if button.UpdateUsable then
                    hooksecurefunc(button, "UpdateUsable", Tint)
                end
                if button.Update then
                    hooksecurefunc(button, "Update", Tint)
                end
            end
        end
    end
    if ActionButton_UpdateUsable and not ns.globalUsableHooked then
        ns.globalUsableHooked = true
        hooksecurefunc("ActionButton_UpdateUsable", Tint)
    end
end

function ns.RefreshTint()
    CollectButtons()
    for button in pairs(buttons) do Tint(button) end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
frame:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
frame:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
frame:RegisterEvent("ACTIONBAR_UPDATE_USABLE")
frame:RegisterEvent("SPELL_UPDATE_USABLE")
frame:SetScript("OnEvent", function() ns.RefreshTint() end)

ns.On("STATE", ns.RefreshTint)
ns.On("STANCE_CHANGED", function() C_Timer.After(0, ns.RefreshTint) end)
ns.On("ENTERING_WORLD", function() C_Timer.After(1, ns.RefreshTint) end)
