-- Crafting from the bank (server setting Crafting.ReagentsFromBank): the server lets a recipe use reagents in the bank tab
-- and bank bags, but the client's recipe windows only count the bags, so they show 0 available and disable Create. This
-- recounts with the bank after Blizzard's own code has drawn the window: the [n] in the recipe list, the reagent counts,
-- the Create and Create All buttons (TradeSkillFrame). Enchanting's window (CraftFrame): the selected recipe only.

local function ItemCount(link)
    if not link then return nil end
    local id = tonumber(link:match("item:(%d+)"))
    if not id then return nil end
    return GetItemCount(id, true)       -- true: bags and bank
end

-- the API of one window: number of reagents, reagent info, reagent link
local TRADE = {
    num = function(i) return GetTradeSkillNumReagents(i) end,
    info = function(i, r) return GetTradeSkillReagentInfo(i, r) end,
    link = function(i, r) return GetTradeSkillReagentItemLink(i, r) end,
}
local CRAFT = {
    num = function(i) return GetCraftNumReagents(i) end,
    info = function(i, r) return GetCraftReagentInfo(i, r) end,
    link = function(i, r) return GetCraftReagentItemLink(i, r) end,
}

-- how many of the recipe the bags and bank make; nil when a reagent cannot be counted (then Blizzard's numbers stay)
local function Available(api, index)
    local numReagents = api.num(index)
    if not numReagents or numReagents == 0 then return nil end
    local made
    for r = 1, numReagents do
        local _, _, needed = api.info(index, r)
        local have = ItemCount(api.link(index, r))
        if not needed or needed == 0 or not have then return nil end
        local n = math.floor(have / needed)
        made = made and math.min(made, n) or n
    end
    return made
end

-- the selected recipe's reagent lines: count, grey or white, and whether all are there
local function RedrawReagents(api, index, prefix)
    local creatable = true
    for r = 1, api.num(index) or 0 do
        local reagentName, reagentTexture, needed = api.info(index, r)
        local have = ItemCount(api.link(index, r))
        local reagent = _G[prefix .. r]
        if reagentName and reagentTexture and have and reagent then
            local name, count = _G[prefix .. r .. "Name"], _G[prefix .. r .. "Count"]
            if have < needed then
                creatable = false
                SetItemButtonTextureVertexColor(reagent, 0.5, 0.5, 0.5)
                name:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
            else
                SetItemButtonTextureVertexColor(reagent, 1.0, 1.0, 1.0)
                name:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
            end
            count:SetText((have >= 100 and "*" or have) .. " /" .. needed)
        elseif reagentName then
            return nil                  -- uncountable: leave Blizzard's state
        end
    end
    return creatable
end

---------------------------------------------------------------------------------------------------------------------------
-- TradeSkillFrame (Blizzard_TradeSkillUI)

local function TradeSelection(id)
    if not id or id < 1 or id > (GetNumTradeSkills() or 0) then return end
    local skillName, skillType = GetTradeSkillInfo(id)
    if not skillName or skillType == "header" then return end
    local creatable = RedrawReagents(TRADE, id, "TradeSkillReagent")
    if creatable == nil then return end
    TradeSkillCreateButton:SetEnabled(creatable)
    TradeSkillCreateAllButton:SetEnabled(creatable)
end

local function TradeUpdate()
    local offset = FauxScrollFrame_GetOffset(TradeSkillListScrollFrame)
    local numSkills = GetNumTradeSkills() or 0
    for i = 1, TRADE_SKILLS_DISPLAYED do
        local index = i + offset
        if index > numSkills then break end
        local button = _G["TradeSkillSkill" .. i]
        local skillName, skillType = GetTradeSkillInfo(index)
        if button and button:IsShown() and skillName and skillType ~= "header" then
            local made = Available(TRADE, index)
            if made then
                button:SetText(" " .. skillName .. (made > 0 and (" [" .. made .. "]") or ""))
                if GetTradeSkillSelectionIndex() == index then
                    TradeSkillFrame.numAvailable = made
                end
            end
        end
    end
    local selected = GetTradeSkillSelectionIndex()
    if selected and selected > 0 and selected <= numSkills then
        local made = Available(TRADE, selected)
        if made then TradeSkillFrame.numAvailable = made end
    end
end

---------------------------------------------------------------------------------------------------------------------------
-- CraftFrame (Blizzard_CraftUI: Enchanting; Beast Training has no reagents and is left alone)

-- Only the selected recipe is recounted here, and only after checking its index: unlike the tradeskill window, the list's
-- [n] counts are left to the client (asking the craft API about every visible entry was suspected of crashing the client).
local function CraftSelection(id)
    if not id or id < 1 or id > (GetNumCrafts() or 0) then return end
    local craftName, _, craftType = GetCraftInfo(id)
    if not craftName or craftType == "header" or craftType == "used" then return end
    local creatable = RedrawReagents(CRAFT, id, "CraftReagent")
    if creatable == nil then return end
    CraftCreateButton:SetEnabled(creatable)
end

---------------------------------------------------------------------------------------------------------------------------

local hooked = {}
local function Hook()
    if not hooked.trade and TradeSkillFrame_SetSelection then
        hooked.trade = true
        hooksecurefunc("TradeSkillFrame_SetSelection", TradeSelection)
        hooksecurefunc("TradeSkillFrame_Update", TradeUpdate)
    end
    if not hooked.craft and CraftFrame_SetSelection then
        hooked.craft = true
        hooksecurefunc("CraftFrame_SetSelection", CraftSelection)
    end
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", Hook)
