-- Apply to the `world` database; restart worldserver (or `.reload quest_template`). Every quest on a 055 row had none before.
UPDATE quest_template SET ContentTuningID = 0 WHERE ContentTuningID BETWEEN 8100001 AND 8100059;
