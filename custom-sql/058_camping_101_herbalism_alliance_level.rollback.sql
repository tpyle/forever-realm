-- Apply to the `world` database; restart worldserver (or `.reload quest_template`).
DELETE FROM quest_template_classic_level WHERE ID = 97921;
DELETE FROM quest_classic_level WHERE ID = 97921;
UPDATE quest_template SET ContentTuningID = 0 WHERE ID = 97921;
