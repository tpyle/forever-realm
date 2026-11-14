-- Forever Stances: the client side of the realm's class stances (server ClassStance.h). Shared state and events.
local _, ns = ...

ns.FIRST_STANCE_SPELL = 8104019
ns.CLASSES = { 1, 2, 3, 4, 5, 7, 8, 9, 11 }          -- in the order of the stance spells
ns.CLASS_NAMES = { [1] = "Warrior", [2] = "Paladin", [3] = "Hunter", [4] = "Rogue", [5] = "Priest", [7] = "Shaman",
                   [8] = "Mage", [9] = "Warlock", [11] = "Druid" }

-- what the server last told us (STATE): the real class, learned stance classes, the active one, talent points per class
ns.state = { realClass = nil, learned = {}, active = 0, alwaysActive = true, points = {}, known = false }
ns.skills = {}

function ns.StanceSpell(classId)
    for i, c in ipairs(ns.CLASSES) do
        if c == classId then return ns.FIRST_STANCE_SPELL + i - 1 end
    end
end

function ns.ClassName(classId)
    if GetClassInfo then
        local name = GetClassInfo(classId)
        if name then return name end
    end
    return ns.CLASS_NAMES[classId] or ("Class " .. tostring(classId))
end

function ns.Print(text)
    DEFAULT_CHAT_FRAME:AddMessage("|cff69ccf0Forever Stances:|r " .. text)
end

-- the class stance active right now, read from the player's auras (0 for none)
function ns.ActiveStanceFromAuras()
    for i, classId in ipairs(ns.CLASSES) do
        local spell = ns.FIRST_STANCE_SPELL + i - 1
        local aura
        if C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID then
            local ok, result = pcall(C_UnitAuras.GetPlayerAuraBySpellID, spell)
            aura = ok and result or nil
        end
        if aura then return classId end
    end
    return 0
end

-- listeners: ns.On("STATE", fn) and so on; ns.Fire runs them
local listeners = {}
function ns.On(event, fn)
    listeners[event] = listeners[event] or {}
    table.insert(listeners[event], fn)
end
function ns.Fire(event, ...)
    for _, fn in ipairs(listeners[event] or {}) do
        local ok, err = pcall(fn, ...)
        if not ok then ns.Print("error in " .. event .. ": " .. tostring(err)) end
    end
end

-- work that has to wait for the end of combat (action bars, secure buttons)
local afterCombat = {}
function ns.AfterCombat(key, fn)
    if InCombatLockdown() then
        afterCombat[key] = fn
    else
        fn()
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterUnitEvent("UNIT_AURA", "player")
frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "ForeverStances" then
        ForeverStancesDB = ForeverStancesDB or {}
        local db = ForeverStancesDB
        db.layouts = db.layouts or {}
        if db.separateBars == nil then db.separateBars = true end
        ns.db = db
        -- settings shared by every character of the account (the talent window's size)
        ForeverStancesAccountDB = ForeverStancesAccountDB or {}
        ns.accountDb = ForeverStancesAccountDB
        if ns.accountDb.talentScale == nil and db.talentScale then
            ns.accountDb.talentScale = db.talentScale
        end
        db.talentScale = nil
        ns.Fire("LOADED")
    elseif event == "PLAYER_ENTERING_WORLD" then
        ns.Fire("ENTERING_WORLD")
    elseif event == "PLAYER_REGEN_ENABLED" then
        local pending = afterCombat
        afterCombat = {}
        for _, fn in pairs(pending) do fn() end
    elseif event == "UNIT_AURA" then
        local active = ns.ActiveStanceFromAuras()
        if active ~= ns.auraStance then
            ns.auraStance = active
            ns.Fire("STANCE_CHANGED", active)
        end
    end
end)

SLASH_FOREVERSTANCES1 = "/stance"
SLASH_FOREVERSTANCES2 = "/stances"
SlashCmdList.FOREVERSTANCES = function(msg)
    msg = (msg or ""):lower():match("^%s*(.-)%s*$")
    if msg == "ping" then
        ns.Ping()
    elseif msg == "talents" or msg == "t" then
        ns.ToggleTalents()
    elseif msg:match("^scale") then
        local value = tonumber(msg:match("^scale%s+([%d%.]+)"))
        if value then
            ns.Print(string.format("talent window scale %.2f", ns.SetTalentScale(value)))
        else
            ns.Print("/stance scale <0.6-2>: the size of the talent window (or drag its bottom right corner). Default 1.25.")
        end
    elseif msg == "help" then
        ns.Print("/stance: the stance panel. /stance talents: the talent window. /stance scale <0.6-2>: its size. /stance ping: test the link to the server.")
    else
        ns.TogglePanel()
    end
end
