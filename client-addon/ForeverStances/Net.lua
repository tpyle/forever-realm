-- Messages with the server: addon whispers to yourself under the prefix FSTANCE. The server answers them and never passes
-- them on, so nothing reaches other players.
local _, ns = ...

local PREFIX = "FSTANCE"
-- our own requests come back to us as the whisper's echo: only the server's answers are read
local ANSWERS = { PONG = true, STATE = true, TALB = true, TAL = true, TALE = true, SKLB = true, SKL = true, SKLE = true, ERR = true }

local registered = false
local function Register()
    if registered then return true end
    local reg = (C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix) or RegisterAddonMessagePrefix
    if reg then
        local ok, result = pcall(reg, PREFIX)
        registered = ok and result ~= false
    end
    return registered
end

local queue, sending = {}, false
local function Pump()
    local text = table.remove(queue, 1)
    if not text then sending = false return end
    sending = true
    local send = (C_ChatInfo and C_ChatInfo.SendAddonMessage) or SendAddonMessage
    local ok, result = pcall(send, PREFIX, text, "WHISPER", UnitName("player"))
    local throttled = ok and (result == 3 or result == 8)
    if throttled then
        table.insert(queue, 1, text)
        C_Timer.After(1.0, Pump)
    else
        C_Timer.After(0.15, Pump)
    end
end

function ns.Send(text)
    Register()
    table.insert(queue, text)
    if not sending then Pump() end
end

local pingSent
function ns.Ping()
    pingSent = GetTime()
    ns.Send("PING")
    C_Timer.After(5, function()
        if pingSent then
            ns.Print("the server did not answer (no PONG in 5 seconds).")
            pingSent = nil
        end
    end)
end

-- collected lists (TALB/TAL/TALE, SKLB/SKL/SKLE)
local talentParts, skillParts = {}, nil

local handlers = {}
function handlers.PONG()
    if pingSent then
        ns.Print(string.format("the server answered in %d ms.", (GetTime() - pingSent) * 1000))
        pingSent = nil
    end
end

function handlers.STATE(args)
    -- STATE <real class> <learned mask> <active class> <always active> <class:points:spent;...>
    local real, mask, active, always, points = args:match("^(%d+) (%d+) (%d+) (%d+) ?(.*)$")
    if not real then return end
    local state = ns.state
    state.realClass = tonumber(real)
    state.active = tonumber(active)
    state.alwaysActive = always == "1"
    state.learned = {}
    state.points = {}
    mask = tonumber(mask)
    for _, classId in ipairs(ns.CLASSES) do
        if bit.band(mask, bit.lshift(1, classId - 1)) ~= 0 then
            table.insert(state.learned, classId)
        end
    end
    for classId, total, spent in (points or ""):gmatch("(%d+):(%d+):(%d+)") do
        state.points[tonumber(classId)] = { total = tonumber(total), spent = tonumber(spent) }
    end
    state.known = true
    ns.Fire("STATE")
end

function handlers.TALB(args)
    talentParts[tonumber(args)] = {}
end

function handlers.TAL(args)
    local classId, list = args:match("^(%d+) (.*)$")
    classId = tonumber(classId)
    if not classId then return end
    talentParts[classId] = talentParts[classId] or {}
    for id, rank in list:gmatch("(%d+):(%d+)") do
        talentParts[classId][tonumber(id)] = tonumber(rank)
    end
end

function handlers.TALE(args)
    local classId, total, spent = args:match("^(%d+) (%d+) (%d+)$")
    classId = tonumber(classId)
    if not classId then return end
    ns.talents = ns.talents or {}
    ns.talents[classId] = talentParts[classId] or {}
    talentParts[classId] = nil
    ns.state.points[classId] = { total = tonumber(total), spent = tonumber(spent) }
    ns.Fire("TALENTS", classId)
end

function handlers.SKLB()
    skillParts = {}
end

function handlers.SKL(args)
    skillParts = skillParts or {}
    for entry in args:gmatch("[^;]+") do
        local category, value, max, name = entry:match("^(%d+):(%d+):(%d+):(.*)$")
        if category then
            table.insert(skillParts, { category = tonumber(category), value = tonumber(value), max = tonumber(max), name = name })
        end
    end
end

function handlers.SKLE()
    ns.skills = skillParts or {}
    skillParts = nil
    table.sort(ns.skills, function(a, b)
        if a.category ~= b.category then return a.category < b.category end
        return a.name < b.name
    end)
    ns.Fire("SKILLS")
end

function handlers.ERR(args)
    UIErrorsFrame:AddMessage(args, 1.0, 0.1, 0.1)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_ADDON")
frame:SetScript("OnEvent", function(_, _, prefix, text)
    if prefix ~= PREFIX or type(text) ~= "string" then return end
    if issecretvalue and issecretvalue(text) then return end
    local command, args = text:match("^(%u+) ?(.*)$")
    if command and ANSWERS[command] and handlers[command] then
        handlers[command](args or "")
    end
end)

ns.On("ENTERING_WORLD", function()
    Register()
    C_Timer.After(2, function() ns.Send("HELLO") end)
end)
