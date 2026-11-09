-- Pick Lock (1804) at every blacksmith trainer, for anyone with Blacksmithing (164) at level 16, at the rogue price
-- (18 silver; rogue trainers teach it at 16 too). The trainers are the ones teaching the Blacksmithing ranks (2018, 3100,
-- 3538, 9785). Needs 060 for the Lockpicking skill. Pick Lock uses Thieves' Tools (5060), which any class can use.
-- Apply to the `world` database; restart worldserver.
INSERT INTO trainer_spell (TrainerId, SpellId, MoneyCost, ReqSkillLine, ReqSkillRank, ReqAbility1, ReqAbility2, ReqAbility3, ReqLevel, VerifiedBuild)
SELECT DISTINCT TrainerId, 1804, 1800, 164, 1, 0, 0, 0, 16, 0 FROM trainer_spell WHERE SpellId IN (2018, 3100, 3538, 9785)
ON DUPLICATE KEY UPDATE MoneyCost = VALUES(MoneyCost), ReqSkillLine = VALUES(ReqSkillLine), ReqSkillRank = VALUES(ReqSkillRank), ReqLevel = VALUES(ReqLevel);
