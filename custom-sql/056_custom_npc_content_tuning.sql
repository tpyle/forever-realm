-- The custom NPCs (8103001-8103029: the added trainers and Fizzle Everhand) have no vanilla level (creature_classic_level),
-- so the server sizes them by their ContentTuning, which they took from the creatures they were copied from (70, 72, 73,
-- 378, 864, 866, 1477). None of those is in the client's data, so they were all level 1. Give them the 1-60 row (055):
-- they show each player at that player's level, like retail service NPCs, and are level 60 to the server.
-- Apply to the `world` database; restart worldserver.
UPDATE creature_template_difficulty SET ContentTuningID = 8100001 WHERE Entry BETWEEN 8103001 AND 8103029 AND DifficultyID = 0;
