-- Weapon skills for the new race/class combinations. Apply to the `hotfixes` database; restart worldserver.
-- SkillRaceClassInfo (table hash 112059424) decides who may have a skill: Availability 1 = starts with it,
-- 0 = trains it at a weapon master. Without a matching row a character can never have the skill.
-- Everything here is trainable, as for most stock races, except Bows for undead and gnome hunters,
-- who need it for their starting bow. Flags 0x80 as in the stock rows. Race mask bits: race - 1, and
-- 32/33 (RaceMask2 bits 0/1) for the Sky Elf races 95/96.
DELETE FROM skill_race_class_info WHERE ID BETWEEN 2561 AND 2568;
INSERT INTO skill_race_class_info (ID, SkillID, ClassMask, Flags, Availability, MinLevel, SkillTierID, RaceMask1, RaceMask2, VerifiedBuild) VALUES
  -- Druid (0x400): human, orc, dwarf, undead, gnome, troll
  (2561,  54, 1024, 128, 0, 0, 0, 215, 0, 70790),  -- Maces
  (2562, 173, 1024, 128, 0, 0, 0, 215, 0, 70790),  -- Daggers
  -- Hunter (0x4): undead, gnome
  (2563,  44,    4, 128, 0, 0, 0,  80, 0, 70790),  -- Axes
  (2564,  46,    4, 128, 0, 0, 0,  80, 0, 70790),  -- Guns
  (2565,  45,    4, 128, 1, 0, 0,  80, 0, 70790),  -- Bows, from the start
  -- Sky Elves (both races)
  (2566,  43,  258, 128, 0, 0, 0,   0, 3, 70790),  -- Swords: paladin, warlock
  (2567,  55,    2, 128, 0, 0, 0,   0, 3, 70790),  -- Two-Handed Swords: paladin
  (2568, 173,   16, 128, 0, 0, 0,   0, 3, 70790);  -- Daggers: priest

DELETE FROM hotfix_data WHERE Id BETWEEN 81000386 AND 81000393;
INSERT INTO hotfix_data (Id, UniqueId, TableHash, RecordId, Status, VerifiedBuild) VALUES
  (81000386, 81000386, 112059424, 2561, 1, 70790),
  (81000387, 81000387, 112059424, 2562, 1, 70790),
  (81000388, 81000388, 112059424, 2563, 1, 70790),
  (81000389, 81000389, 112059424, 2564, 1, 70790),
  (81000390, 81000390, 112059424, 2565, 1, 70790),
  (81000391, 81000391, 112059424, 2566, 1, 70790),
  (81000392, 81000392, 112059424, 2567, 1, 70790),
  (81000393, 81000393, 112059424, 2568, 1, 70790);
