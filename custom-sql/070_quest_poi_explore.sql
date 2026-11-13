-- Map areas for the explore step of exploration quests (written by tools/quest_poi_explore.py). Their quest_poi had
-- only the turn-in point, so the map showed nothing until the area was explored. One blob per quest around its
-- area triggers, as the objective's POI (as live data has for other quests).
-- Apply to the `world` database; `reload quest_poi` (no restart). Clients see it after a relog.
-- quest 62: triggers 88, 197
DELETE FROM quest_poi WHERE QuestID=62 AND QuestObjectiveID=90000620;
DELETE FROM quest_poi_points WHERE QuestID=62 AND Idx1=2;
INSERT INTO quest_poi (QuestID, BlobIndex, Idx1, ObjectiveIndex, QuestObjectiveID, QuestObjectID, MapID, UiMapID, Priority, Flags, VerifiedBuild) VALUES (62, 0, 2, 0, 90000620, 0, 0, 1429, 0, 1, 0);
INSERT INTO quest_poi_points (QuestID, Idx1, Idx2, X, Y, Z, VerifiedBuild) VALUES
  (62, 2, 0, -9864, 128, 15, 0),
  (62, 2, 1, -9858, 113, 15, 0),
  (62, 2, 2, -9844, 108, 15, 0),
  (62, 2, 3, -9829, 113, 15, 0),
  (62, 2, 4, -9782, 144, 15, 0),
  (62, 2, 5, -9776, 158, 15, 0),
  (62, 2, 6, -9782, 172, 15, 0),
  (62, 2, 7, -9796, 178, 15, 0),
  (62, 2, 8, -9810, 172, 15, 0),
  (62, 2, 9, -9858, 142, 15, 0);
-- quest 76: triggers 87
DELETE FROM quest_poi WHERE QuestID=76 AND QuestObjectiveID=385473;
DELETE FROM quest_poi_points WHERE QuestID=76 AND Idx1=2;
INSERT INTO quest_poi (QuestID, BlobIndex, Idx1, ObjectiveIndex, QuestObjectiveID, QuestObjectID, MapID, UiMapID, Priority, Flags, VerifiedBuild) VALUES (76, 0, 2, 0, 385473, 0, 0, 1429, 0, 1, 0);
INSERT INTO quest_poi_points (QuestID, Idx1, Idx2, X, Y, Z, VerifiedBuild) VALUES
  (76, 2, 0, -9107, -553, 60, 0),
  (76, 2, 1, -9099, -574, 60, 0),
  (76, 2, 2, -9077, -583, 60, 0),
  (76, 2, 3, -9056, -574, 60, 0),
  (76, 2, 4, -9047, -553, 60, 0),
  (76, 2, 5, -9056, -532, 60, 0),
  (76, 2, 6, -9077, -523, 60, 0),
  (76, 2, 7, -9099, -532, 60, 0);
-- quest 201: triggers 98
DELETE FROM quest_poi WHERE QuestID=201 AND QuestObjectiveID=385476;
DELETE FROM quest_poi_points WHERE QuestID=201 AND Idx1=2;
INSERT INTO quest_poi (QuestID, BlobIndex, Idx1, ObjectiveIndex, QuestObjectiveID, QuestObjectID, MapID, UiMapID, Priority, Flags, VerifiedBuild) VALUES (201, 0, 2, 0, 385476, 0, 0, 1434, 0, 1, 0);
INSERT INTO quest_poi_points (QuestID, Idx1, Idx2, X, Y, Z, VerifiedBuild) VALUES
  (201, 2, 0, -11665, -54, 13, 0),
  (201, 2, 1, -11656, -75, 13, 0),
  (201, 2, 2, -11635, -84, 13, 0),
  (201, 2, 3, -11614, -75, 13, 0),
  (201, 2, 4, -11605, -54, 13, 0),
  (201, 2, 5, -11614, -33, 13, 0),
  (201, 2, 6, -11635, -24, 13, 0),
  (201, 2, 7, -11656, -33, 13, 0);
-- quest 578: triggers 196
DELETE FROM quest_poi WHERE QuestID=578 AND QuestObjectiveID=385482;
DELETE FROM quest_poi_points WHERE QuestID=578 AND Idx1=2;
INSERT INTO quest_poi (QuestID, BlobIndex, Idx1, ObjectiveIndex, QuestObjectiveID, QuestObjectID, MapID, UiMapID, Priority, Flags, VerifiedBuild) VALUES (578, 0, 2, 0, 385482, 0, 0, 1434, 0, 1, 0);
INSERT INTO quest_poi_points (QuestID, Idx1, Idx2, X, Y, Z, VerifiedBuild) VALUES
  (578, 2, 0, -12234, 894, 10, 0),
  (578, 2, 1, -12210, 837, 10, 0),
  (578, 2, 2, -12154, 814, 10, 0),
  (578, 2, 3, -12097, 837, 10, 0),
  (578, 2, 4, -12074, 894, 10, 0),
  (578, 2, 5, -12097, 951, 10, 0),
  (578, 2, 6, -12154, 974, 10, 0),
  (578, 2, 7, -12210, 951, 10, 0);
-- quest 944: triggers 223
DELETE FROM quest_poi WHERE QuestID=944 AND QuestObjectiveID=385489;
DELETE FROM quest_poi_points WHERE QuestID=944 AND Idx1=3;
INSERT INTO quest_poi (QuestID, BlobIndex, Idx1, ObjectiveIndex, QuestObjectiveID, QuestObjectID, MapID, UiMapID, Priority, Flags, VerifiedBuild) VALUES (944, 0, 3, 0, 385489, 0, 1, 1439, 0, 1, 0);
INSERT INTO quest_poi_points (QuestID, Idx1, Idx2, X, Y, Z, VerifiedBuild) VALUES
  (944, 3, 0, 4448, 373, 33, 0),
  (944, 3, 1, 4466, 331, 33, 0),
  (944, 3, 2, 4508, 313, 33, 0),
  (944, 3, 3, 4551, 331, 33, 0),
  (944, 3, 4, 4568, 373, 33, 0),
  (944, 3, 5, 4551, 416, 33, 0),
  (944, 3, 6, 4508, 433, 33, 0),
  (944, 3, 7, 4466, 416, 33, 0);
-- quest 1149: triggers 246
DELETE FROM quest_poi WHERE QuestID=1149 AND QuestObjectiveID=385491;
DELETE FROM quest_poi_points WHERE QuestID=1149 AND Idx1=2;
INSERT INTO quest_poi (QuestID, BlobIndex, Idx1, ObjectiveIndex, QuestObjectiveID, QuestObjectID, MapID, UiMapID, Priority, Flags, VerifiedBuild) VALUES (1149, 0, 2, 0, 385491, 0, 1, 1441, 0, 1, 0);
INSERT INTO quest_poi_points (QuestID, Idx1, Idx2, X, Y, Z, VerifiedBuild) VALUES
  (1149, 2, 0, -4953, -1596, 85, 0),
  (1149, 2, 1, -4947, -1610, 85, 0),
  (1149, 2, 2, -4933, -1616, 85, 0),
  (1149, 2, 3, -4918, -1610, 85, 0),
  (1149, 2, 4, -4913, -1596, 85, 0),
  (1149, 2, 5, -4918, -1582, 85, 0),
  (1149, 2, 6, -4933, -1576, 85, 0),
  (1149, 2, 7, -4947, -1582, 85, 0);
-- quest 1265: triggers 1667
DELETE FROM quest_poi WHERE QuestID=1265 AND QuestObjectiveID=385516;
DELETE FROM quest_poi_points WHERE QuestID=1265 AND Idx1=2;
INSERT INTO quest_poi (QuestID, BlobIndex, Idx1, ObjectiveIndex, QuestObjectiveID, QuestObjectID, MapID, UiMapID, Priority, Flags, VerifiedBuild) VALUES (1265, 0, 2, 0, 385516, 0, 1, 1445, 0, 1, 0);
INSERT INTO quest_poi_points (QuestID, Idx1, Idx2, X, Y, Z, VerifiedBuild) VALUES
  (1265, 2, 0, -3485, -4121, 17, 0),
  (1265, 2, 1, -3479, -4135, 17, 0),
  (1265, 2, 2, -3465, -4141, 17, 0),
  (1265, 2, 3, -3451, -4135, 17, 0),
  (1265, 2, 4, -3445, -4121, 17, 0),
  (1265, 2, 5, -3451, -4107, 17, 0),
  (1265, 2, 6, -3465, -4101, 17, 0),
  (1265, 2, 7, -3479, -4107, 17, 0);
-- quest 1448: triggers 362
DELETE FROM quest_poi WHERE QuestID=1448 AND QuestObjectiveID=385492;
DELETE FROM quest_poi_points WHERE QuestID=1448 AND Idx1=2;
INSERT INTO quest_poi (QuestID, BlobIndex, Idx1, ObjectiveIndex, QuestObjectiveID, QuestObjectID, MapID, UiMapID, Priority, Flags, VerifiedBuild) VALUES (1448, 0, 2, 0, 385492, 0, 0, 1429, 0, 1, 0);
INSERT INTO quest_poi_points (QuestID, Idx1, Idx2, X, Y, Z, VerifiedBuild) VALUES
  (1448, 2, 0, -10579, -3829, -32, 0),
  (1448, 2, 1, -10536, -3935, -32, 0),
  (1448, 2, 2, -10429, -3979, -32, 0),
  (1448, 2, 3, -10323, -3935, -32, 0),
  (1448, 2, 4, -10279, -3829, -32, 0),
  (1448, 2, 5, -10323, -3723, -32, 0),
  (1448, 2, 6, -10429, -3679, -32, 0),
  (1448, 2, 7, -10536, -3723, -32, 0);
-- quest 1658: triggers 3991
DELETE FROM quest_poi WHERE QuestID=1658 AND QuestObjectiveID=385504;
DELETE FROM quest_poi_points WHERE QuestID=1658 AND Idx1=2;
INSERT INTO quest_poi (QuestID, BlobIndex, Idx1, ObjectiveIndex, QuestObjectiveID, QuestObjectID, MapID, UiMapID, Priority, Flags, VerifiedBuild) VALUES (1658, 0, 2, 0, 385504, 0, 0, 1424, 0, 1, 0);
INSERT INTO quest_poi_points (QuestID, Idx1, Idx2, X, Y, Z, VerifiedBuild) VALUES
  (1658, 2, 0, 1698, 526, 34, 0),
  (1658, 2, 1, 1709, 502, 34, 0),
  (1658, 2, 2, 1733, 491, 34, 0),
  (1658, 2, 3, 1758, 502, 34, 0),
  (1658, 2, 4, 1768, 526, 34, 0),
  (1658, 2, 5, 1758, 551, 34, 0),
  (1658, 2, 6, 1733, 561, 34, 0),
  (1658, 2, 7, 1709, 551, 34, 0);
-- quest 1699: triggers 482
DELETE FROM quest_poi WHERE QuestID=1699 AND QuestObjectiveID=385494;
DELETE FROM quest_poi_points WHERE QuestID=1699 AND Idx1=2;
INSERT INTO quest_poi (QuestID, BlobIndex, Idx1, ObjectiveIndex, QuestObjectiveID, QuestObjectID, MapID, UiMapID, Priority, Flags, VerifiedBuild) VALUES (1699, 0, 2, 0, 385494, 0, 0, 1433, 0, 1, 0);
INSERT INTO quest_poi_points (QuestID, Idx1, Idx2, X, Y, Z, VerifiedBuild) VALUES
  (1699, 2, 0, -8953, -1986, 140, 0),
  (1699, 2, 1, -8947, -2001, 140, 0),
  (1699, 2, 2, -8933, -2006, 140, 0),
  (1699, 2, 3, -8919, -2001, 140, 0),
  (1699, 2, 4, -8913, -1986, 140, 0),
  (1699, 2, 5, -8919, -1972, 140, 0),
  (1699, 2, 6, -8933, -1966, 140, 0),
  (1699, 2, 7, -8947, -1972, 140, 0);
-- quest 2989: triggers 1205
DELETE FROM quest_poi WHERE QuestID=2989 AND QuestObjectiveID=90029890;
DELETE FROM quest_poi_points WHERE QuestID=2989 AND Idx1=2;
INSERT INTO quest_poi (QuestID, BlobIndex, Idx1, ObjectiveIndex, QuestObjectiveID, QuestObjectID, MapID, UiMapID, Priority, Flags, VerifiedBuild) VALUES (2989, 0, 2, 0, 90029890, 0, 0, 1425, 0, 1, 0);
INSERT INTO quest_poi_points (QuestID, Idx1, Idx2, X, Y, Z, VerifiedBuild) VALUES
  (2989, 2, 0, -316, -3461, 194, 0),
  (2989, 2, 1, -310, -3475, 194, 0),
  (2989, 2, 2, -296, -3481, 194, 0),
  (2989, 2, 3, -281, -3475, 194, 0),
  (2989, 2, 4, -276, -3461, 194, 0),
  (2989, 2, 5, -281, -3447, 194, 0),
  (2989, 2, 6, -296, -3441, 194, 0),
  (2989, 2, 7, -310, -3447, 194, 0);
-- quest 4811: triggers 2486
DELETE FROM quest_poi WHERE QuestID=4811 AND QuestObjectiveID=385519;
DELETE FROM quest_poi_points WHERE QuestID=4811 AND Idx1=2;
INSERT INTO quest_poi (QuestID, BlobIndex, Idx1, ObjectiveIndex, QuestObjectiveID, QuestObjectID, MapID, UiMapID, Priority, Flags, VerifiedBuild) VALUES (4811, 0, 2, 0, 385519, 0, 1, 1439, 0, 1, 0);
INSERT INTO quest_poi_points (QuestID, Idx1, Idx2, X, Y, Z, VerifiedBuild) VALUES
  (4811, 2, 0, 6188, -153, 80, 0),
  (4811, 2, 1, 6193, -167, 80, 0),
  (4811, 2, 2, 6208, -173, 80, 0),
  (4811, 2, 3, 6222, -167, 80, 0),
  (4811, 2, 4, 6228, -153, 80, 0),
  (4811, 2, 5, 6222, -139, 80, 0),
  (4811, 2, 6, 6208, -133, 80, 0),
  (4811, 2, 7, 6193, -139, 80, 0);
-- quest 4842: triggers 2327
DELETE FROM quest_poi WHERE QuestID=4842 AND QuestObjectiveID=385518;
DELETE FROM quest_poi_points WHERE QuestID=4842 AND Idx1=2;
INSERT INTO quest_poi (QuestID, BlobIndex, Idx1, ObjectiveIndex, QuestObjectiveID, QuestObjectID, MapID, UiMapID, Priority, Flags, VerifiedBuild) VALUES (4842, 0, 2, 0, 385518, 0, 1, 1452, 0, 1, 0);
INSERT INTO quest_poi_points (QuestID, Idx1, Idx2, X, Y, Z, VerifiedBuild) VALUES
  (4842, 2, 0, 4969, -4564, 852, 0),
  (4842, 2, 1, 4984, -4599, 852, 0),
  (4842, 2, 2, 5019, -4614, 852, 0),
  (4842, 2, 3, 5054, -4599, 852, 0),
  (4842, 2, 4, 5069, -4564, 852, 0),
  (4842, 2, 5, 5054, -4529, 852, 0),
  (4842, 2, 6, 5019, -4514, 852, 0),
  (4842, 2, 7, 4984, -4529, 852, 0);
-- quest 6025: triggers 3366
DELETE FROM quest_poi WHERE QuestID=6025 AND QuestObjectiveID=385496;
DELETE FROM quest_poi_points WHERE QuestID=6025 AND Idx1=2;
INSERT INTO quest_poi (QuestID, BlobIndex, Idx1, ObjectiveIndex, QuestObjectiveID, QuestObjectID, MapID, UiMapID, Priority, Flags, VerifiedBuild) VALUES (6025, 0, 2, 0, 385496, 0, 0, 1422, 0, 1, 0);
INSERT INTO quest_poi_points (QuestID, Idx1, Idx2, X, Y, Z, VerifiedBuild) VALUES
  (6025, 2, 0, 2812, -1540, 190, 0),
  (6025, 2, 1, 2818, -1555, 190, 0),
  (6025, 2, 2, 2832, -1560, 190, 0),
  (6025, 2, 3, 2846, -1555, 190, 0),
  (6025, 2, 4, 2852, -1540, 190, 0),
  (6025, 2, 5, 2846, -1526, 190, 0),
  (6025, 2, 6, 2832, -1520, 190, 0),
  (6025, 2, 7, 2818, -1526, 190, 0);
-- quest 8286: triggers 3986
DELETE FROM quest_poi WHERE QuestID=8286 AND QuestObjectiveID=90082860;
DELETE FROM quest_poi_points WHERE QuestID=8286 AND Idx1=2;
INSERT INTO quest_poi (QuestID, BlobIndex, Idx1, ObjectiveIndex, QuestObjectiveID, QuestObjectID, MapID, UiMapID, Priority, Flags, VerifiedBuild) VALUES (8286, 0, 2, 0, 90082860, 0, 1, 1451, 0, 1, 0);
INSERT INTO quest_poi_points (QuestID, Idx1, Idx2, X, Y, Z, VerifiedBuild) VALUES
  (8286, 2, 0, -8224, -4676, 11, 0),
  (8286, 2, 1, -8215, -4698, 11, 0),
  (8286, 2, 2, -8194, -4706, 11, 0),
  (8286, 2, 3, -8173, -4698, 11, 0),
  (8286, 2, 4, -8164, -4676, 11, 0),
  (8286, 2, 5, -8173, -4655, 11, 0),
  (8286, 2, 6, -8194, -4646, 11, 0),
  (8286, 2, 7, -8215, -4655, 11, 0);
