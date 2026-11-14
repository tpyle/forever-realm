-- Apply to the `world` database; restart worldserver.
UPDATE quest_template_addon SET PrevQuestID = 98581 WHERE ID = 94373;
UPDATE quest_template_addon SET NextQuestID = 0 WHERE ID IN (98581, 96243);
