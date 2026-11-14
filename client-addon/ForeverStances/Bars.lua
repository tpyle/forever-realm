-- An action bar layout per class stance: leaving a stance saves what is on the main bar (slots 1-12) and the stance and
-- form bars (73-120), entering one puts back what was there last time in that stance. A stance's first layout is empty.
-- Stances change only out of combat, when an addon may move actions.
local _, ns = ...

local SLOTS = {}
for slot = 1, 12 do table.insert(SLOTS, slot) end
for slot = 73, 120 do table.insert(SLOTS, slot) end

local function Key(classId)
    return classId == 0 and "own" or tostring(classId)
end

local function Save(key)
    local layout = {}
    for _, slot in ipairs(SLOTS) do
        local ok, actionType, id, subType = pcall(GetActionInfo, slot)
        if ok and actionType and id and not (issecretvalue and issecretvalue(id)) then
            layout[slot] = { actionType, id, subType }
        end
    end
    ns.db.layouts[key] = layout
end

local function PickUp(entry)
    local actionType, id = entry[1], entry[2]
    if actionType == "spell" then
        if C_Spell and C_Spell.PickupSpell then C_Spell.PickupSpell(id) else PickupSpell(id) end
    elseif actionType == "item" then
        if C_Item and C_Item.PickupItem then C_Item.PickupItem(id) else PickupItem(id) end
    elseif actionType == "macro" then
        PickupMacro(id)
    elseif actionType == "equipmentset" and C_EquipmentSet then
        C_EquipmentSet.PickupEquipmentSet(id)
    end
end

local function Restore(key)
    local layout = ns.db.layouts[key] or {}
    ClearCursor()
    for _, slot in ipairs(SLOTS) do
        local want = layout[slot]
        local ok, actionType, id = pcall(GetActionInfo, slot)
        local have = ok and actionType and { actionType, id } or nil
        local same = (want == nil and have == nil) or (want and have and want[1] == have[1] and want[2] == have[2])
        if not same then
            if have then
                PickupAction(slot)
                ClearCursor()
            end
            if want then
                PickUp(want)
                if GetCursorInfo() then
                    PlaceAction(slot)
                end
                ClearCursor()
            end
        end
    end
end

local ready = false             -- auras settle after login; until then the bars stay those we logged out with

local function Switch(newClass)
    if not ready then return end
    if not ns.db or not ns.db.separateBars then
        if ns.db then ns.db.current = Key(newClass) end
        return
    end
    local newKey = Key(newClass)
    local oldKey = ns.db.current
    if oldKey == newKey then return end
    ns.AfterCombat("bars", function()
        if ns.db.current ~= oldKey then return end
        if oldKey then Save(oldKey) end
        Restore(newKey)
        ns.db.current = newKey
        ns.RefreshTint()
    end)
end

ns.On("STANCE_CHANGED", Switch)

-- at login the bars are those of the stance we logged out in
ns.On("ENTERING_WORLD", function()
    ready = false
    C_Timer.After(3, function()
        ns.auraStance = ns.ActiveStanceFromAuras()
        if ns.db then ns.db.current = Key(ns.auraStance) end
        ready = true
    end)
end)

function ns.SetSeparateBars(on)
    ns.db.separateBars = on
    ns.db.current = Key(ns.ActiveStanceFromAuras())
end
