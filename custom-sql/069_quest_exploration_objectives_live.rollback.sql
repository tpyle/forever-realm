-- Apply to the `world` database; restart worldserver.
DELETE FROM quest_objectives WHERE ID IN (385473, 385476, 385482, 385489, 385491, 385516, 385492, 385504, 385494, 385513, 385519, 385518, 385496);
INSERT INTO quest_objectives (`ID`,`QuestID`,`Type`,`Order`,`StorageIndex`,`ObjectID`,`Amount`,`ConditionalAmount`,`Flags`,`Flags2`,`ProgressBarWeight`,`ParentObjectiveID`,`Visible`,`Description`,`VerifiedBuild`) VALUES
  (90002730,273,10, 0, 0, -1, 1, 0, 0, 0, 0, 0, 1, 'Find Huldar, Miran, and Saean', 0),
  (90000760,76,10, 0, 0, -1, 1, 0, 0, 0, 0, 0, 1, 'Scout through the Jasperlode Mine', 0),
  (90002010,201,10, 0, 0, -1, 1, 0, 0, 0, 0, 0, 1, 'Locate the hunters'' camp', 0),
  (90005780,578,10, 0, 0, -1, 1, 0, 0, 0, 0, 0, 1, 'Locate the haunted island', 0),
  (90009440,944,10, 0, 0, -1, 1, 0, 0, 0, 0, 0, 1, 'Enter the Master''s Glaive', 0),
  (90011490,1149,10, 0, 0, -1, 1, 0, 0, 0, 0, 0, 1, 'Leap from the planks overlooking Thousand Needles', 0),
  (90012650,1265,10, 0, 0, -1, 1, 0, 0, 0, 0, 0, 1, 'Sentry Point explored', 0),
  (90014480,1448,10, 0, 0, -1, 1, 0, 0, 0, 0, 0, 1, 'Search for the Temple of Atal''Hakkar', 0),
  (90016580,1658,10, 0, 0, -1, 1, 0, 0, 0, 0, 0, 1, 'Scout out the Forsaken''s Wickerman Festival.', 0),
  (90016990,1699,10, 0, 0, -1, 1, 0, 0, 0, 0, 0, 1, 'Enter the Rethban Caverns', 0),
  (90022400,2240,10, 0, 0, -1, 1, 0, 0, 0, 0, 0, 1, 'Explore the Hidden Chamber', 0),
  (90048110,4811,10, 0, 0, -1, 1, 0, 0, 0, 0, 0, 1, 'Locate the large, red crystal on Darkshore''s eastern mountain range', 0),
  (90048420,4842,10, 0, 0, -1, 1, 0, 0, 0, 0, 0, 1, 'Discover Darkwhisper Gorge', 0),
  (90060250,6025,10, 0, 0, -1, 1, 0, 0, 0, 0, 0, 1, 'Overlook Hearthglen from a high vantage point', 0);
