-- Stance action bars. The server keeps the main bar (slots 1-12) and the stance and form bars (73-120) per class stance and
-- swaps them at a stance change (ClassStance::IsSeparateActionBars); the other bars are the same in every stance. Up to 1.4
-- this addon swapped them itself, saving each stance's layout in ForeverStancesDB.layouts: those are sent to the server once.
local _, ns = ...

local SLOTS = {}
for slot = 1, 12 do table.insert(SLOTS, slot) end
for slot = 73, 120 do table.insert(SLOTS, slot) end

local TYPES = { spell = 0, macro = 64, item = 128 }     -- ActionButtonType

-- the layouts the addon kept, as the server keeps them (class 0: the real class's)
local function Upload()
    local sent = 0
    for key, layout in pairs(ns.db.layouts or {}) do
        local classId = key == "own" and 0 or tonumber(key)
        if classId then
            local entries = {}
            for _, slot in ipairs(SLOTS) do
                local entry = layout[slot]
                local actionType = entry and TYPES[entry[1]]
                if actionType and type(entry[2]) == "number" then
                    table.insert(entries, ("%d:%d:%d"):format(slot, actionType, entry[2]))
                end
            end
            ns.Send("BARSETB " .. classId)
            local head, line = "BARSET " .. classId .. " ", ""
            for _, text in ipairs(entries) do
                if #head + #line + #text + 1 > 240 then
                    ns.Send(head .. line)
                    line = ""
                end
                line = line == "" and text or (line .. "," .. text)
            end
            if line ~= "" then ns.Send(head .. line) end
            ns.Send("BARSETE " .. classId)
            sent = sent + 1
        end
    end
    ns.db.barsUploaded = true
    if sent > 0 then
        ns.Print(("the server now keeps each stance's action bars; your %d saved layout%s were sent to it."):format(sent, sent == 1 and "" or "s"))
    end
end

-- BARS <1|0>: the server keeps a set per stance (or one for all)
ns.On("BARS", function(on)
    ns.serverBars = on
    if on and ns.db and not ns.db.barsUploaded then Upload() end
    if ns.RefreshPanel then ns.RefreshPanel() end
end)

-- /stance bars reset: every other stance's main and stance bars start empty; the active one's stay
function ns.ResetBars()
    ns.Send("BARRESET")
    ns.Print("the other stances' bar layouts are cleared on the server: this one keeps the bar you see, the others start empty.")
end

-- after a login or /reload: the active stance from the auras once they have settled (the rest of the addon reads it; the
-- server's STATE then keeps it)
ns.On("ENTERING_WORLD", function(fresh)
    if not fresh then return end
    C_Timer.After(3, function() ns.auraStance = ns.ActiveStanceFromAuras() end)
end)
