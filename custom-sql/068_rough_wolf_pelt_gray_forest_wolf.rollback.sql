-- Apply to the `world` database; `reload creature_loot_template`, and restart for the quest-item row.
DELETE FROM creature_loot_template WHERE Entry = 1922 AND ItemType = 0 AND Item = 247877;
DELETE FROM creature_questitem WHERE CreatureEntry = 1922 AND DifficultyID = 0 AND ItemId = 247877;
