-- Fizzle Everhand's spawn was cloned from Durga Lightsworn's and kept her model, which overrides
-- the goblin model on his template. Apply to the `world` database. Takes effect after a worldserver restart.
UPDATE creature SET modelid = 0 WHERE guid = 26300003;
