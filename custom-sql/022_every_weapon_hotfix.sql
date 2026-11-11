-- Every race and class can train every weapon skill. Apply to the `hotfixes` database; restart worldserver.
-- Needs 023_wands_at_weapon_masters.sql too, since no trainer taught Wands before.
--
-- SkillRaceClassInfo (hash 112059424): one trainable row (Availability 0) per weapon skill for all nine
-- classes (mask 1503) and all ten races (RaceMask1 255 = races 1-8, RaceMask2 3 = Sky Elves 95/96).
-- SkillLineAbility (hash 4282664694): each weapon spell is also limited by class, so each stock row gets a
-- copy for the classes it leaves out, including the spells that come with a skill (Shoot Bow, Shoot Gun,
-- Shoot Crossbow, Throw, Shoot). Hunters are left out of the three Shoot spells: they use Auto Shot.
-- Values other than ClassMask are copied from the stock row.
DELETE FROM skill_race_class_info WHERE ID BETWEEN 2601 AND 2615;
INSERT INTO skill_race_class_info (ID, SkillID, ClassMask, Flags, Availability, MinLevel, SkillTierID, RaceMask1, RaceMask2, VerifiedBuild) VALUES
  (2601, 44, 1503, 128, 0, 0, 0, 255, 3, 70790),  -- Axes
  (2602, 172, 1503, 128, 0, 0, 0, 255, 3, 70790),  -- Two-Handed Axes
  (2603, 45, 1503, 128, 0, 0, 0, 255, 3, 70790),  -- Bows
  (2604, 46, 1503, 128, 0, 0, 0, 255, 3, 70790),  -- Guns
  (2605, 54, 1503, 128, 0, 0, 0, 255, 3, 70790),  -- Maces
  (2606, 160, 1503, 128, 0, 0, 0, 255, 3, 70790),  -- Two-Handed Maces
  (2607, 229, 1503, 128, 0, 0, 0, 255, 3, 70790),  -- Polearms
  (2608, 43, 1503, 128, 0, 0, 0, 255, 3, 70790),  -- Swords
  (2609, 55, 1503, 128, 0, 0, 0, 255, 3, 70790),  -- Two-Handed Swords
  (2610, 136, 1503, 128, 0, 0, 0, 255, 3, 70790),  -- Staves
  (2611, 473, 1503, 130, 0, 0, 0, 255, 3, 70790),  -- Fist Weapons
  (2612, 173, 1503, 128, 0, 0, 0, 255, 3, 70790),  -- Daggers
  (2613, 176, 1503, 128, 0, 0, 0, 255, 3, 70790),  -- Thrown
  (2614, 226, 1503, 128, 0, 0, 0, 255, 3, 70790),  -- Crossbows
  (2615, 228, 1503, 128, 0, 0, 0, 255, 3, 70790);  -- Wands

DELETE FROM skill_line_ability WHERE ID BETWEEN 60001 AND 60020;
INSERT INTO skill_line_ability (ID, AbilityVerb, AbilityAllVerb, SkillLine, Spell, MinSkillLineRank, ClassMask, SupercedesSpell, AcquireMethod, TrivialSkillLineRankHigh, TrivialSkillLineRankLow, Flags, NumSkillUps, UniqueBit, TradeSkillCategoryID, SkillupSkillLineID, Field_5_5_4_67090_0141, Field_5_5_4_67090_0142, RaceMask1, RaceMask2, VerifiedBuild) VALUES
  (60001, '', '', 45, 264, 1, 1490, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 70790),  -- Bows spell 264: paladin,priest,shaman,mage,warlock,druid
  (60002, '', '', 44, 196, 1, 1424, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 70790),  -- Axes spell 196: priest,mage,warlock,druid
  (60003, '', '', 46, 266, 1, 1490, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, -1, -1, 70790),  -- Guns spell 266: paladin,priest,shaman,mage,warlock,druid
  (60004, '', '', 43, 201, 1, 1104, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 70790),  -- Swords spell 201: priest,shaman,druid
  (60005, '', '', 54, 198, 1, 388, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 70790),  -- Maces spell 198: hunter,mage,warlock
  (60006, '', '', 55, 202, 1, 1496, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 70790),  -- Two-Handed Swords spell 202: rogue,priest,shaman,mage,warlock,druid
  (60007, '', '', 136, 227, 1, 10, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 70790),  -- Staves spell 227: paladin,rogue
  (60008, '', '', 173, 1180, 1, 2, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 70790),  -- Daggers spell 1180: paladin
  (60009, '', '', 176, 2567, 1, 1490, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 70790),  -- Thrown spell 2567: paladin,priest,shaman,mage,warlock,druid
  (60010, '', '', 176, 2764, 1, 1490, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 70790),  -- Thrown spell 2764: paladin,priest,shaman,mage,warlock,druid
  (60011, '', '', 228, 5009, 1, 1103, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 70790),  -- Wands spell 5009: warrior,paladin,hunter,rogue,shaman,druid
  (60012, '', '', 229, 200, 1, 472, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 70790),  -- Polearms spell 200: rogue,priest,shaman,mage,warlock
  (60013, '', '', 226, 5011, 1, 1490, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, -1, -1, 70790),  -- Crossbows spell 5011: paladin,priest,shaman,mage,warlock,druid
  (60014, '', '', 228, 5019, 1, 1103, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 70790),  -- Wands spell 5019: warrior,paladin,hunter,rogue,shaman,druid
  (60015, '', '', 172, 197, 1, 1432, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 70790),  -- Two-Handed Axes spell 197: rogue,priest,mage,warlock,druid
  (60016, '', '', 160, 199, 1, 412, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 70790),  -- Two-Handed Maces spell 199: hunter,rogue,priest,mage,warlock
  (60017, '', '', 45, 2480, 1, 1490, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 70790),  -- Bows spell 2480: paladin,priest,shaman,mage,warlock,druid
  (60018, '', '', 226, 7919, 1, 1490, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, -1, -1, 70790),  -- Crossbows spell 7919: paladin,priest,shaman,mage,warlock,druid
  (60019, '', '', 46, 7918, 1, 1490, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, -1, -1, 70790),  -- Guns spell 7918: paladin,priest,shaman,mage,warlock,druid
  (60020, '', '', 473, 15590, 1, 402, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 70790);  -- Fist Weapons spell 15590: paladin,priest,mage,warlock

DELETE FROM hotfix_data WHERE Id BETWEEN 81000401 AND 81000435;
INSERT INTO hotfix_data (Id, UniqueId, TableHash, RecordId, Status, VerifiedBuild) VALUES
  (81000401, 81000401, 112059424, 2601, 1, 70790),
  (81000402, 81000402, 112059424, 2602, 1, 70790),
  (81000403, 81000403, 112059424, 2603, 1, 70790),
  (81000404, 81000404, 112059424, 2604, 1, 70790),
  (81000405, 81000405, 112059424, 2605, 1, 70790),
  (81000406, 81000406, 112059424, 2606, 1, 70790),
  (81000407, 81000407, 112059424, 2607, 1, 70790),
  (81000408, 81000408, 112059424, 2608, 1, 70790),
  (81000409, 81000409, 112059424, 2609, 1, 70790),
  (81000410, 81000410, 112059424, 2610, 1, 70790),
  (81000411, 81000411, 112059424, 2611, 1, 70790),
  (81000412, 81000412, 112059424, 2612, 1, 70790),
  (81000413, 81000413, 112059424, 2613, 1, 70790),
  (81000414, 81000414, 112059424, 2614, 1, 70790),
  (81000415, 81000415, 112059424, 2615, 1, 70790),
  (81000416, 81000416, 4282664694, 60001, 1, 70790),
  (81000417, 81000417, 4282664694, 60002, 1, 70790),
  (81000418, 81000418, 4282664694, 60003, 1, 70790),
  (81000419, 81000419, 4282664694, 60004, 1, 70790),
  (81000420, 81000420, 4282664694, 60005, 1, 70790),
  (81000421, 81000421, 4282664694, 60006, 1, 70790),
  (81000422, 81000422, 4282664694, 60007, 1, 70790),
  (81000423, 81000423, 4282664694, 60008, 1, 70790),
  (81000424, 81000424, 4282664694, 60009, 1, 70790),
  (81000425, 81000425, 4282664694, 60010, 1, 70790),
  (81000426, 81000426, 4282664694, 60011, 1, 70790),
  (81000427, 81000427, 4282664694, 60012, 1, 70790),
  (81000428, 81000428, 4282664694, 60013, 1, 70790),
  (81000429, 81000429, 4282664694, 60014, 1, 70790),
  (81000430, 81000430, 4282664694, 60015, 1, 70790),
  (81000431, 81000431, 4282664694, 60016, 1, 70790),
  (81000432, 81000432, 4282664694, 60017, 1, 70790),
  (81000433, 81000433, 4282664694, 60018, 1, 70790),
  (81000434, 81000434, 4282664694, 60019, 1, 70790),
  (81000435, 81000435, 4282664694, 60020, 1, 70790);
