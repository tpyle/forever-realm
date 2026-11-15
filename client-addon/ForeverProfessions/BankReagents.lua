-- Crafting from the bank (server setting Crafting.ReagentsFromBank): the server lets a recipe use reagents in the bank tab
-- and bank bags, but the client's Professions window counted only the bags, showed the reagents as missing and disabled
-- Create.
--
-- The 1.60 client uses retail's Blizzard_Professions. Every reagent count it shows or checks goes through
-- ItemUtil.GetCraftingReagentCount (Blizzard_FrameXMLUtil/ItemUtil.lua), which includes the bank only when the client
-- function ReagentsFromBankAllowed() returns true; on this client it returns false, and no server setting changes it.
-- Replacing that global makes the window count the bank: reagent counts, quality allocation, Create and Create All.
-- The [n] in the recipe list comes from C_TradeSkillUI (counted inside the client) and still shows bags only.

local blizzardReagentsFromBankAllowed = ReagentsFromBankAllowed

ReagentsFromBankAllowed = function()
    return true
end

SLASH_FOREVERBANKREAGENTS1 = "/bankreagents"
SlashCmdList.FOREVERBANKREAGENTS = function()
    print(("Forever Professions: reagents from the bank are counted (client's own setting: %s)."):format(
        blizzardReagentsFromBankAllowed and tostring(blizzardReagentsFromBankAllowed()) or "missing"))
end
