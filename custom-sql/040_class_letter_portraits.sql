-- No portrait on the custom class quests, like the stock class letters: the one copied from Glyphic Letter showed as a
-- blank grey box in this client. Apply to the `world` database; restart worldserver.
UPDATE quest_template SET PortraitGiver = 0, PortraitGiverName = NULL, PortraitGiverText = NULL WHERE ID BETWEEN 9100301 AND 9100307;
