-- Exploration quest objectives as the live realm has them. Upstream's world 2026_10_25_02 gave 19 vanilla exploration quests a
-- placeholder objective (area trigger -1, IDs 9000xxxx). Its later 2026_11_12_03 adds the live objectives (the trigger the client
-- sends, EG Link data, CC BY 4.0), but only where a quest has none yet, so for these 13 the live rows never went in. For The Missing
-- Diplomat (1265) that left the Sentry Point step on the old trigger 302 instead of the 1667 the client sends.
-- 1. Quest 273 (Resupplying the Excavation) is not an exploration quest (Huldar's SmartAI credits its objective 9000273, Speak
--    with Huldar) and has no trigger: the placeholder 90002730 could never be credited, so the quest could not be turned in.
-- 2. The 13 quests: the placeholder replaced by the live row (same StorageIndex 0, so progress on the quest carries over).
-- 1149's live row has no text; it keeps the placeholder's.
-- The Fargodeep Mine (62) has no live row and keeps its placeholder; How Big a Threat? (984) has triggers the client lacks.
-- Apply to the `world` database; restart worldserver. Clients that cached these quests need their Cache folder deleted.
DELETE FROM quest_objectives WHERE ID = 90002730;
DELETE FROM quest_objectives WHERE ID IN (90000760, 90002010, 90005780, 90009440, 90011490, 90012650, 90014480, 90016580, 90016990, 90022400, 90048110, 90048420, 90060250);
DELETE FROM quest_objectives WHERE ID IN (385473, 385476, 385482, 385489, 385491, 385516, 385492, 385504, 385494, 385513, 385519, 385518, 385496);
INSERT INTO quest_objectives (`ID`,`QuestID`,`Type`,`Order`,`StorageIndex`,`ObjectID`,`Amount`,`ConditionalAmount`,`Flags`,`Flags2`,`ProgressBarWeight`,`ParentObjectiveID`,`Visible`,`Description`,`VerifiedBuild`) VALUES
  (385473,76,10,0,0,87,1,0,0,0,0,0,1,'Scout through the Jasperlode Mine',0),
  (385476,201,10,0,0,98,1,0,0,0,0,0,1,'Locate the hunters\' camp',0),
  (385482,578,10,0,0,196,1,0,0,0,0,0,1,'Locate the haunted island',0),
  (385489,944,10,0,0,223,0,0,0,0,0,0,1,'Enter the Master\'s Glaive',0),
  (385491,1149,10,0,0,246,1,0,0,0,0,0,1,'Leap from the planks overlooking Thousand Needles',0),
  (385516,1265,10,0,0,1667,1,0,0,0,0,0,1,'Sentry Point explored',0),
  (385492,1448,10,0,0,362,1,0,0,0,0,0,1,'Search for the Temple of Atal\'Hakkar',0),
  (385504,1658,10,0,0,3991,1,0,0,0,0,0,1,'Scout out the Forsaken\'s Wickerman Festival.',0),
  (385494,1699,10,0,0,482,1,0,0,0,0,0,1,'Enter the Rethban Caverns',0),
  (385513,2240,10,0,0,822,1,0,0,0,0,0,1,'Explore the Hidden Chamber',0),
  (385519,4811,10,0,0,2486,1,0,0,0,0,0,1,'Locate the large, red crystal on Darkshore\'s eastern mountain range',0),
  (385518,4842,10,0,0,2327,1,0,0,0,0,0,1,'Discover Darkwhisper Gorge',0),
  (385496,6025,10,0,0,3366,1,0,0,0,0,0,1,'Overlook Hearthglen from a high vantage point',0);
