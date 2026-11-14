-- While a class stance is active, a client key (its binding) and micro button open one of our windows instead of the
-- client's own: an override binding on the binding's keys and a button laid over the micro button, both removed when the
-- stance ends, so out of a stance the client's own are untouched. Stances change only out of combat, when bindings may.
local _, ns = ...

local intercepts = {}

local function Active()
    local active = ns.auraStance or ns.ActiveStanceFromAuras()
    return active and active ~= 0 and active or nil
end

local function MicroButton(names)
    for _, name in ipairs(names) do
        local b = _G[name]
        if b and b:IsShown() then return b end
    end
    for _, name in ipairs(names) do
        if _G[name] then return _G[name] end
    end
end

local function Update(it)
    local active = Active()
    local on = active ~= nil and it.enabled(active)

    -- changing a binding fires UPDATE_BINDINGS again: only change them when something did
    local keys = { GetBindingKey(it.binding) }
    local signature = (on and "on:" or "off:") .. table.concat(keys, ",")
    if signature ~= it.signature then
        it.signature = signature
        ClearOverrideBindings(it.owner)
        if on then
            for _, key in ipairs(keys) do
                SetOverrideBindingClick(it.owner, true, key, it.buttonName)
            end
        end
    end

    local micro = MicroButton(it.microButtons)
    if micro and not it.overlay then
        local overlay = CreateFrame("Button", nil, micro)
        overlay:SetAllPoints(micro)
        overlay:RegisterForClicks("AnyUp")
        overlay:SetScript("OnClick", function() it.toggle(Active()) end)
        overlay:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(it.title)
            GameTooltip:AddLine("Your " .. ns.ClassName(Active() or 0) .. " " .. it.what, 1, 1, 1)
            GameTooltip:Show()
        end)
        overlay:SetScript("OnLeave", GameTooltip_Hide)
        it.overlay = overlay
    end
    if it.overlay then
        it.overlay:SetFrameLevel(it.overlay:GetParent():GetFrameLevel() + 10)
        it.overlay:SetShown(on)
    end
end

local function RefreshAll()
    ns.AfterCombat("intercepts", function()
        for _, it in ipairs(intercepts) do Update(it) end
    end)
end

-- ns.Intercept{ name, binding, microButtons, title, what, toggle = fn(activeClass), enabled = fn(activeClass) }
function ns.Intercept(it)
    it.buttonName = "ForeverStances" .. it.name .. "Toggle"
    it.enabled = it.enabled or function() return true end
    local button = CreateFrame("Button", it.buttonName, UIParent)
    button:SetScript("OnClick", function()
        local active = Active()
        if active then it.toggle(active) end
    end)
    it.owner = CreateFrame("Frame")
    table.insert(intercepts, it)
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("UPDATE_BINDINGS")
events:SetScript("OnEvent", RefreshAll)
ns.On("ENTERING_WORLD", function() C_Timer.After(3, RefreshAll) end)
ns.On("STANCE_CHANGED", RefreshAll)
