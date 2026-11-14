-- Call of Earth (94373), the shaman's quest from Teo Hammerstorm in Anvilmar, asked for Archaic Rune (98581, PrevQuestID), which
-- only dwarves and gnomes can take. Shamans of the other races (every race may be a shaman here, 001-003, and class stances)
-- come to Teo by the other Call of Earth (96243, from the shaman trainers in Kharanos and Ironforge) and then found nothing.
-- Either quest now opens it: both name it as their NextQuestID (ExclusiveGroup 0: any one of them), and it asks for no single one.
-- Apply to the `world` database; restart worldserver.
UPDATE quest_template_addon SET PrevQuestID = 0 WHERE ID = 94373;
UPDATE quest_template_addon SET NextQuestID = 94373 WHERE ID IN (98581, 96243);
