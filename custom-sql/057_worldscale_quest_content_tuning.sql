-- World scaling for quests (core WorldScale.h). A vanilla quest of level N (quest_template_classic_level, 1-59) gets the
-- ContentTuning row 8100000 + N (custom-sql 055: levels N to 60). The client then shows the quest at the player's level,
-- never below N (tested: its ContentTuning overrides the fixed level), so low quests no longer read as trivial. The server
-- keeps level N for the reward and pays part of the way to a quest of the player's level (WorldScale.QuestXPFraction).
-- Left out: quests without a minimum level (quest_classic_level), which would take N from the row as their minimum
-- (117 Thunderbrew, 7838 Arena Grandmaster). Clients keep quest details in their Cache folder: delete it once to see this.
-- Apply to the `world` database; restart worldserver (or `.reload quest_template`).
UPDATE quest_template q
    JOIN quest_template_classic_level c ON c.ID = q.ID
    JOIN quest_classic_level m ON m.ID = q.ID
SET q.ContentTuningID = 8100000 + c.QuestLevel
WHERE c.QuestLevel BETWEEN 1 AND 59 AND m.MinLevel > 0
    AND (q.ContentTuningID = 0 OR q.ContentTuningID BETWEEN 8100001 AND 8100059);
