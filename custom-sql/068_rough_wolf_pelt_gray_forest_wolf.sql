-- Rough Wolf Pelt (247877, quest 91751 "Rough Wolf Pelts") also drops from Gray Forest Wolf (1922), at 40% while the
-- quest needs it, as from Prowler (118). Wowhead lists both wolves; upstream only had the Prowler. The creature_questitem
-- row makes the client mark the wolf as a source of the quest item.
-- Apply to the `world` database. The loot works after `reload creature_loot_template`; the quest-item row needs a restart.
DELETE FROM creature_loot_template WHERE Entry = 1922 AND ItemType = 0 AND Item = 247877;
INSERT INTO creature_loot_template (Entry, ItemType, Item, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment) VALUES
  (1922, 0, 247877, 40, 1, 1, 0, 1, 1, 'Rough Wolf Pelt, quest 91751 (custom-sql 068)');
DELETE FROM creature_questitem WHERE CreatureEntry = 1922 AND DifficultyID = 0 AND ItemId = 247877;
INSERT INTO creature_questitem (CreatureEntry, DifficultyID, Idx, ItemId, VerifiedBuild) VALUES
  (1922, 0, 0, 247877, 0);
