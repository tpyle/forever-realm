-- The class quests in 034 and 037 were copied from a Northshire one and rewarded Stormwind reputation. Use the faction
-- of their starting zone, like the stock letters there: Ironforge (47) for Coldridge Valley (as the dwarf runes and
-- Archaic Rune; the quest is for dwarves and gnomes), Darnassus (69) for Shadowglen (as the sigils).
-- Apply to the `world` database; restart worldserver.
UPDATE quest_template SET RewardFactionID1 = 47 WHERE ID = 9100303;
UPDATE quest_template SET RewardFactionID1 = 69 WHERE ID BETWEEN 9100304 AND 9100307;
