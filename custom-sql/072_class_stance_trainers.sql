-- Class stances (TrinityCore game/Entities/Player/ClassStance.h, spells from 071): every class trainer sells its class's
-- stance (1 gold, from level 10) to the other classes; the stance spells' script.
-- Apply to the `world` database; restart worldserver.
DELETE FROM trainer_spell WHERE SpellId IN (8104019, 8104020, 8104021, 8104022, 8104023, 8104024, 8104025, 8104026, 8104027);
INSERT INTO trainer_spell (TrainerId, SpellId, MoneyCost, ReqSkillLine, ReqSkillRank, ReqAbility1, ReqAbility2, ReqAbility3, ReqLevel, VerifiedBuild) VALUES
  (22, 8104019, 10000, 0, 0, 0, 0, 0, 10, 0),
  (23, 8104019, 10000, 0, 0, 0, 0, 0, 10, 0),
  (28, 8104020, 10000, 0, 0, 0, 0, 0, 10, 0),
  (29, 8104020, 10000, 0, 0, 0, 0, 0, 10, 0),
  (19, 8104021, 10000, 0, 0, 0, 0, 0, 10, 0),
  (20, 8104021, 10000, 0, 0, 0, 0, 0, 10, 0),
  (25, 8104022, 10000, 0, 0, 0, 0, 0, 10, 0),
  (26, 8104022, 10000, 0, 0, 0, 0, 0, 10, 0),
  (1006707, 8104022, 10000, 0, 0, 0, 0, 0, 10, 0),
  (7, 8104023, 10000, 0, 0, 0, 0, 0, 10, 0),
  (8, 8104023, 10000, 0, 0, 0, 0, 0, 10, 0),
  (1005994, 8104023, 10000, 0, 0, 0, 0, 0, 10, 0),
  (10, 8104024, 10000, 0, 0, 0, 0, 0, 10, 0),
  (11, 8104024, 10000, 0, 0, 0, 0, 0, 10, 0),
  (1, 8104025, 10000, 0, 0, 0, 0, 0, 10, 0),
  (5, 8104025, 10000, 0, 0, 0, 0, 0, 10, 0),
  (114, 8104025, 10000, 0, 0, 0, 0, 0, 10, 0),
  (139, 8104025, 10000, 0, 0, 0, 0, 0, 10, 0),
  (140, 8104025, 10000, 0, 0, 0, 0, 0, 10, 0),
  (144, 8104025, 10000, 0, 0, 0, 0, 0, 10, 0),
  (149, 8104025, 10000, 0, 0, 0, 0, 0, 10, 0),
  (1000331, 8104025, 10000, 0, 0, 0, 0, 0, 10, 0),
  (13, 8104026, 10000, 0, 0, 0, 0, 0, 10, 0),
  (14, 8104026, 10000, 0, 0, 0, 0, 0, 10, 0),
  (17, 8104027, 10000, 0, 0, 0, 0, 0, 10, 0),
  (1233, 8104027, 10000, 0, 0, 0, 0, 0, 10, 0);
DELETE FROM spell_script_names WHERE spell_id IN (8104019, 8104020, 8104021, 8104022, 8104023, 8104024, 8104025, 8104026, 8104027);
INSERT INTO spell_script_names (spell_id, ScriptName) VALUES
  (8104019, 'spell_class_stance'),
  (8104020, 'spell_class_stance'),
  (8104021, 'spell_class_stance'),
  (8104022, 'spell_class_stance'),
  (8104023, 'spell_class_stance'),
  (8104024, 'spell_class_stance'),
  (8104025, 'spell_class_stance'),
  (8104026, 'spell_class_stance'),
  (8104027, 'spell_class_stance');
