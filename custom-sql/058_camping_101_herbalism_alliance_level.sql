-- 97921 Camping 101: Herbalism (Alliance: Sam Sarsaparilla to Herbalist Pomeroy) had no Classic level rows, so it showed as
-- level 0 and gave no experience. Give it the level of its Horde and neutral versions (97957, 97968: level 6, from level 4)
-- and, like them, the world scaling row of its level (057).
-- Apply to the `world` database; restart worldserver (or `.reload quest_template`).
INSERT INTO quest_template_classic_level (ID, LevelType, QuestLevel) VALUES (97921, 2, 6)
    ON DUPLICATE KEY UPDATE LevelType = VALUES(LevelType), QuestLevel = VALUES(QuestLevel);
INSERT INTO quest_classic_level (ID, QuestLevel, MinLevel, MaxLevel) VALUES (97921, 6, 4, 0)
    ON DUPLICATE KEY UPDATE QuestLevel = VALUES(QuestLevel), MinLevel = VALUES(MinLevel), MaxLevel = VALUES(MaxLevel);
UPDATE quest_template SET ContentTuningID = 8100006 WHERE ID = 97921;
