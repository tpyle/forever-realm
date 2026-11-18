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

-- the class stance active right now (0 for none). The server says so in every STATE message (it sends one at each stance change);
-- the auras are only read out of combat: in combat the client hides aura details from addons and answers with a stand-in
-- value, which read as "Warrior Stance is active" (a paladin's seal in combat swapped in the warrior bar and greyed out every
-- paladin spell until combat ended, 2026-11-14).
function ns.ActiveStanceFromAuras()
    if InCombatLockdown() or not (C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID) then
        return ns.auraStance or ns.state.active or 0
    end
    for i, classId in ipairs(ns.CLASSES) do
        local ok, aura = pcall(C_UnitAuras.GetPlayerAuraBySpellID, ns.FIRST_STANCE_SPELL + i - 1)
        if ok and aura ~= nil and not (issecretvalue and issecretvalue(aura)) then
            local id = aura.spellId
            if id ~= nil and not (issecretvalue and issecretvalue(id)) and id == ns.FIRST_STANCE_SPELL + i - 1 then
                return classId
            end
        end
    end
    return 0
end

-- a new active stance, from the server or the auras: tell the rest of the addon once
function ns.SetActiveStance(active)
    if active ~= ns.auraStance then
        ns.auraStance = active
        ns.Fire("STANCE_CHANGED", active)
    end
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
frame:SetScript("OnEvent", function(_, event, arg1, arg2)
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
        -- arg1 isInitialLogin, arg2 isReloadingUi (a loading screen between zones has neither)
        ns.Fire("ENTERING_WORLD", (arg1 or arg2) and true or false)
    elseif event == "PLAYER_REGEN_ENABLED" then
        local pending = afterCombat
        afterCombat = {}
        for _, fn in pairs(pending) do fn() end
    elseif event == "UNIT_AURA" then
        -- in combat the server's STATE says when the stance changes (ActiveStanceFromAuras)
        if not InCombatLockdown() then ns.SetActiveStance(ns.ActiveStanceFromAuras()) end
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
    elseif msg == "spells" or msg == "s" then
        local active = ns.auraStance or ns.ActiveStanceFromAuras()
        local classId = active ~= 0 and active or ns.state.learned[1]
        if classId then ns.ShowSpellbook(classId) else ns.Print("no class stance learned yet.") end
    elseif msg:match("^tree") then
        local classId, generic = msg:match("^tree%s+(%d+)%s*(%a*)")
        if classId then ns.ShowTraitTree(tonumber(classId), generic == "generic") else ns.Print("/stance tree <class id> [generic]") end
    elseif msg == "bars reset" then
        if InCombatLockdown() then ns.Print("not in combat.") else ns.ResetBars() end
    elseif msg:match("^scale") then
        local value = tonumber(msg:match("^scale%s+([%d%.]+)"))
        if value then
            ns.Print(string.format("talent window scale %.2f", ns.SetTalentScale(value)))
        else
            ns.Print("/stance scale <0.6-2>: the size of the talent window (or drag its bottom right corner). Default 1.25.")
        end
    elseif msg == "help" then
        ns.Print("/stance: the stance panel. /stance talents: the talent window. /stance spells: the stance spellbook. /stance scale <0.6-2>: its size. /stance bars reset: forget the stance bar layouts. /stance ping: test the link to the server.")
    else
        ns.TogglePanel()
    end
end

-- a square icon tab (the talent window's classes, its tree headers, the spellbook's skill lines): the name in its tooltip,
-- a gold glow when it is the one shown. tab:Set(icon, tooltip title, tooltip line or nil, selected)
function ns.IconTab(parent, size)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(size, size)
    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetAllPoints()
    b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    b.border = b:CreateTexture(nil, "BACKGROUND")
    b.border:SetPoint("TOPLEFT", -2, 2)
    b.border:SetPoint("BOTTOMRIGHT", 2, -2)
    b.border:SetColorTexture(0, 0, 0, 0.9)
    b.glow = b:CreateTexture(nil, "OVERLAY")
    b.glow:SetTexture("Interface\\Buttons\\CheckButtonHilight")
    b.glow:SetBlendMode("ADD")
    b.glow:SetAllPoints()
    b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    function b:Set(icon, title, line, selected)
        self.icon:SetTexture(icon or 134400)
        self.tipTitle, self.tipLine = title, line
        self.glow:SetShown(selected and true or false)
        if GameTooltip:GetOwner() == self then self:GetScript("OnEnter")(self) end
    end
    b:SetScript("OnEnter", function(self)
        if not self.tipTitle then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(self.tipTitle, 1, 0.82, 0)
        if self.tipLine then GameTooltip:AddLine(self.tipLine, 1, 1, 1, true) end
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", GameTooltip_Hide)
    return b
end

-- a class's icon (the client's ClassIcon_<Class> files)
function ns.ClassIcon(classId)
    local name = ns.CLASS_NAMES[classId]
    return name and ("Interface\\Icons\\ClassIcon_" .. name) or 134400
end
