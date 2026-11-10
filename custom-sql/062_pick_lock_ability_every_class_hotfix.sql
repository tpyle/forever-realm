-- Pick Lock (1804) shown at blacksmith trainers (061) for every class, not just rogues.
-- 060 alone was not enough: the server sent Pick Lock as available, but the client left it out of the trainer list.
-- The stock SkillLineAbility row (8439, Lockpicking 633) has ClassMask 0, and the client then goes by its own
-- rogue-only reading. As 022 does for the weapon spells, this adds a copy of the stock row for the other classes
-- (1495 = 1503 without rogue, 8). Values other than ID and ClassMask are copied from row 8439.
-- SkillLineAbility table hash 4282664694. Apply to the `hotfixes` database; restart worldserver.
DELETE FROM skill_line_ability WHERE ID = 60021;
INSERT INTO skill_line_ability (ID, AbilityVerb, AbilityAllVerb, SkillLine, Spell, MinSkillLineRank, ClassMask, SupercedesSpell, AcquireMethod, TrivialSkillLineRankHigh, TrivialSkillLineRankLow, Flags, NumSkillUps, UniqueBit, TradeSkillCategoryID, SkillupSkillLineID, Field_5_5_4_67090_0141, Field_5_5_4_67090_0142, RaceMask1, RaceMask2, VerifiedBuild) VALUES
  (60021, '', '', 633, 1804, 1, 1495, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 70790);
DELETE FROM hotfix_data WHERE Id = 2001481;
INSERT INTO hotfix_data (Id, UniqueId, TableHash, RecordId, Status, VerifiedBuild) VALUES
  (2001481, 2001481, 4282664694, 60021, 1, 70790);
