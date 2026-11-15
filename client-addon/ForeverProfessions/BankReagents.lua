-- Crafting from the bank (server setting Crafting.ReagentsFromBank): the server lets a recipe use reagents in the bank tab
-- and bank bags, but the client counts only the bags, in its Professions window and again in its own check before it
-- sends a craft ("Missing reagent: ...").
--
-- 1. The window: the 1.60 client uses retail's Blizzard_Professions. Every reagent count it shows or checks goes through
--    ItemUtil.GetCraftingReagentCount (Blizzard_FrameXMLUtil/ItemUtil.lua), which includes the bank only when the client
--    function ReagentsFromBankAllowed() returns true; on this client it returns false, and no server setting changes it.
--    Replacing that global makes the window count the bank: reagent counts, Create and Create All. The [n] in the recipe
--    list comes from C_TradeSkillUI (counted inside the client) and still shows bags only.
-- 2. The craft: when the bags alone do not hold the reagents, C_TradeSkillUI.CraftRecipe / CraftEnchant would be refused
--    by the client, so the craft is asked of the server instead (an addon whisper to yourself, prefix FPROF; the core's
--    scripts/Custom/bank_crafting.cpp casts it with the bank counted). One cast at a time: the next one of a Create All
--    is asked for when the last succeeded, and an interrupted or failed cast stops the rest.

local PREFIX = "FPROF"

local blizzardReagentsFromBankAllowed = ReagentsFromBankAllowed
ReagentsFromBankAllowed = function()
    return true
end

local function BagCount(itemID)
    return C_Item.GetItemCount(itemID, false, false, false, false)
end

-- true when the bags alone lack a required reagent for count crafts
local function NeedsBank(recipeID, count)
    local ok, schematic = pcall(C_TradeSkillUI.GetRecipeSchematic, recipeID, false)
    if not ok or not schematic or not schematic.reagentSlotSchematics then return false end
    for _, slot in ipairs(schematic.reagentSlotSchematics) do
        if slot.required and slot.quantityRequired and slot.quantityRequired > 0 then
            local have = 0
            for _, reagent in ipairs(slot.reagents or {}) do
                if reagent.itemID then have = have + BagCount(reagent.itemID) end
            end
            if have < slot.quantityRequired * math.max(1, count or 1) then
                return true
            end
        end
    end
    return false
end

local registered = false
local function Send(text)
    if not registered then
        local reg = C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix
        registered = reg and pcall(reg, PREFIX) or false
    end
    C_ChatInfo.SendAddonMessage(PREFIX, text, "WHISPER", UnitName("player"))
end

-- the server craft in progress: { spell, remaining, message }
local job

local function Next()
    if not job then return end
    if job.remaining <= 0 then job = nil return end
    job.remaining = job.remaining - 1
    Send(job.message)
end

local function Start(recipeID, count, message)
    job = { spell = recipeID, remaining = math.max(1, count or 1), message = message }
    Next()
end

local blizzardCraftRecipe = C_TradeSkillUI.CraftRecipe
C_TradeSkillUI.CraftRecipe = function(recipeID, numCasts, ...)
    if NeedsBank(recipeID, numCasts) then
        Start(recipeID, numCasts, "CRAFT " .. recipeID)
        return
    end
    return blizzardCraftRecipe(recipeID, numCasts, ...)
end

local blizzardCraftEnchant = C_TradeSkillUI.CraftEnchant
C_TradeSkillUI.CraftEnchant = function(recipeID, numCasts, craftingReagents, itemTarget, ...)
    if itemTarget and NeedsBank(recipeID, numCasts) then
        local ok, guid = pcall(C_Item.GetItemGUID, itemTarget)
        if ok and guid then
            Start(recipeID, numCasts, "ENCH " .. recipeID .. " " .. guid)
            return
        end
    end
    return blizzardCraftEnchant(recipeID, numCasts, craftingReagents, itemTarget, ...)
end

local events = CreateFrame("Frame")
events:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
events:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "player")
events:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "player")
events:SetScript("OnEvent", function(_, event, _, _, spellID)
    if not job or spellID ~= job.spell then return end
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        C_Timer.After(0.2, Next)
    else
        job = nil
    end
end)

SLASH_FOREVERBANKREAGENTS1 = "/bankreagents"
SlashCmdList.FOREVERBANKREAGENTS = function()
    print(("Forever Professions: reagents from the bank are counted (client's own setting: %s)%s."):format(
        blizzardReagentsFromBankAllowed and tostring(blizzardReagentsFromBankAllowed()) or "missing",
        job and (", crafting " .. job.remaining .. " more") or ""))
end
