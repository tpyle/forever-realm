-- Lockpicking (skill 633) for every class, so non-rogues who learn Pick Lock from a blacksmith (061) get the skill it
-- uses. SkillRaceClassInfo (table hash 112059424) had only the rogue row (601, ClassMask 8); without a row for the
-- character's class the skill is never added and Pick Lock opens nothing. Trainable (Availability 0), Flags 0x80 as the
-- stock row, every class (1503) and race (255, Sky Elves 3), as 022 does for the weapon skills.
-- Apply to the `hotfixes` database; restart worldserver.
DELETE FROM skill_race_class_info WHERE ID = 2616;
INSERT INTO skill_race_class_info (ID, SkillID, ClassMask, Flags, Availability, MinLevel, SkillTierID, RaceMask1, RaceMask2, VerifiedBuild) VALUES
  (2616, 633, 1503, 128, 0, 0, 0, 255, 3, 70790);
DELETE FROM hotfix_data WHERE Id = 2001480;
INSERT INTO hotfix_data (Id, UniqueId, TableHash, RecordId, Status, VerifiedBuild) VALUES
  (2001480, 2001480, 112059424, 2616, 1, 70790);
