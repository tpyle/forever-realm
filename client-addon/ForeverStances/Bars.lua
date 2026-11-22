-- An action bar layout per class stance (and one for the real class): the main bar (slots 1-12) and the stance and form
-- bars (73-120). Every change you make to one of those slots is saved at once for the stance you are in; taking another
-- stance puts back that stance's layout. Nothing is saved when the stance changes, so a layout can never be stored under
-- the wrong stance. A stance with no layout yet starts empty. Stances change only out of combat, when an addon may move
-- actions.
local _, ns = ...

local SLOTS, TRACKED = {}, {}
for slot = 1, 12 do table.insert(SLOTS, slot) end
for slot = 73, 120 do table.insert(SLOTS, slot) end
for _, slot in ipairs(SLOTS) do TRACKED[slot] = true end

local ready = false         -- after a login or /reload, until the auras have settled
local restoring = false     -- our own moves fire ACTIONBAR_SLOT_CHANGED too: not the player's changes

local function Key(classId)
    return (classId == nil or classId == 0) and "own" or tostring(classId)
end

local function ActiveKey()
    return Key(ns.auraStance or ns.ActiveStanceFromAuras())
end

local function Read(slot)
    local ok, actionType, id, subType = pcall(GetActionInfo, slot)
    if ok and actionType and id and not (issecretvalue and issecretvalue(id)) then
        return { actionType, id, subType }
    end
end

local function Layout(key)
    ns.db.layouts[key] = ns.db.layouts[key] or {}
    return ns.db.layouts[key]
end

-- the player put something on a slot or took it off: that slot of the active stance's layout
local function SaveSlot(slot)
    if not ready or restoring or not ns.db or not ns.db.separateBars or not TRACKED[slot] then return end
    if InCombatLockdown() then return end
    Layout(ActiveKey())[slot] = Read(slot) or false
end

local function SaveAll(key)
    local layout = Layout(key)
    for _, slot in ipairs(SLOTS) do layout[slot] = Read(slot) or false end
end

local function PickUpSpell(id)
    if C_Spell and C_Spell.PickupSpell then C_Spell.PickupSpell(id) else PickupSpell(id) end
end

-- puts the entry on the cursor; a spell the client will not pick up by its ID (a stance spell such as Charge, right at a
-- stance change) is tried by its base spell and by name
local function PickUp(entry)
    local actionType, id = entry[1], entry[2]
    if actionType == "spell" then
        pcall(PickUpSpell, id)
        if not GetCursorInfo() and FindBaseSpellByID then
            local base = FindBaseSpellByID(id)
            if base and base ~= id then pcall(PickUpSpell, base) end
        end
        if not GetCursorInfo() then
            local name = C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(id)
            if name then pcall(PickUpSpell, name) end
        end
    elseif actionType == "item" then
        if C_Item and C_Item.PickupItem then C_Item.PickupItem(id) else PickupItem(id) end
    elseif actionType == "macro" then
        PickupMacro(id)
    elseif actionType == "equipmentset" and C_EquipmentSet then
        C_EquipmentSet.PickupEquipmentSet(id)
    end
end

local function Same(want, have)
    return (not want and not have) or (want and have and want[1] == have[1] and want[2] == have[2]) or false
end

-- puts the layout on the bars
local function Place(layout)
    ClearCursor()
    for _, slot in ipairs(SLOTS) do
        local want = layout[slot] or nil
        if not Same(want, Read(slot)) then
            if Read(slot) then
                PickupAction(slot)
                ClearCursor()
            end
            if want then
                PickUp(want)
                if GetCursorInfo() then PlaceAction(slot) end
                ClearCursor()
            end
        end
    end
end

local restoreToken = 0

local function Restore(key)
    local layout = ns.db.layouts[key]
    if not layout then
        -- the first time in this stance: an empty bar to fill (the real class keeps what is there)
        if key == "own" then SaveAll(key) return end
        layout = Layout(key)
    end
    restoreToken = restoreToken + 1
    local token = restoreToken
    restoring = true
    Place(layout)
    ns.RefreshTint()
    -- a second pass a moment later, still not saving: a slot the client would not fill at the stance change itself, or one it
    -- emptied just after (it reports the moves late too), gets its action back instead of being saved as empty
    C_Timer.After(1, function()
        if token ~= restoreToken then return end
        if InCombatLockdown() then restoring = false return end
        Place(layout)
        ns.RefreshTint()
        C_Timer.After(0.5, function()
            if token ~= restoreToken then return end
            restoring = false
            for _, slot in ipairs(SLOTS) do
                local want = layout[slot] or nil
                if want and not Same(want, Read(slot)) then
                    local name = want[1] == "spell" and C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(want[2])
                    ns.Print(("could not put back %s on action slot %d (%s %s); it stays in this stance's layout."):format(
                        name or "an action", slot, tostring(want[1]), tostring(want[2])))
                end
            end
        end)
    end)
end

local function Apply()
    if not ready or not ns.db or not ns.db.separateBars then return end
    ns.AfterCombat("bars", function() Restore(ActiveKey()) end)
end

local events = CreateFrame("Frame")
events:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
events:SetScript("OnEvent", function(_, _, slot) SaveSlot(slot) end)

ns.On("STANCE_CHANGED", Apply)

-- after a login or /reload: once the auras have settled, the active stance's layout (no change if it is on the bars)
ns.On("ENTERING_WORLD", function(fresh)
    if not fresh then return end
    ready = false
    C_Timer.After(3, function()
        ns.auraStance = ns.ActiveStanceFromAuras()
        ready = true
        if ns.db then ns.db.current = nil end    -- no longer used (the old bars kept the stance on screen there)
        Apply()
    end)
end)

function ns.SetSeparateBars(on)
    ns.db.separateBars = on
    -- turned on: what is on the bars now is the active stance's layout
    if on then SaveAll(ActiveKey()) end
end

-- /stance bars reset: forget every stance's layout; the bars on screen become the active stance's
function ns.ResetBars()
    ns.db.layouts = {}
    SaveAll(ActiveKey())
    if ActiveKey() == "own" then
        ns.Print("stance bar layouts cleared: your class keeps the bar you see, each stance starts empty.")
    else
        ns.Print("stance bar layouts cleared: this stance keeps the bar you see. Run it outside a class stance to keep your own class's bar instead.")
    end
end
