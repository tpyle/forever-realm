-- Wands at every weapon master, for the classes that could not have it before (022). Apply to the `world`
-- database; restart worldserver. 10 silver, as the weapon masters charge for the other weapons.
DELETE FROM trainer_spell WHERE SpellId = 5009 AND TrainerId IN (397, 398, 399, 400, 1011865, 1011866, 1011867, 1013084);
INSERT INTO trainer_spell (TrainerId, SpellId, MoneyCost, ReqSkillLine, ReqSkillRank, ReqAbility1, ReqAbility2, ReqAbility3, ReqLevel, VerifiedBuild) VALUES
  (397, 5009, 1000, 0, 0, 0, 0, 0, 0, 0),      -- Sayoc, Orgrimmar
  (398, 5009, 1000, 0, 0, 0, 0, 0, 0, 0),      -- Ansekhwa, Thunder Bluff
  (399, 5009, 1000, 0, 0, 0, 0, 0, 0, 0),      -- Hanashi, Orgrimmar
  (400, 5009, 1000, 0, 0, 0, 0, 0, 0, 0),      -- Archibald, Undercity
  (1011865, 5009, 1000, 0, 0, 0, 0, 0, 0, 0),  -- Buliwyf Stonehand, Ironforge
  (1011866, 5009, 1000, 0, 0, 0, 0, 0, 0, 0),  -- Ilyenia Moonfire, Darnassus
  (1011867, 5009, 1000, 0, 0, 0, 0, 0, 0, 0),  -- Woo Ping, Stormwind
  (1013084, 5009, 1000, 0, 0, 0, 0, 0, 0, 0);  -- Bixi Wobblebonk, Ironforge
