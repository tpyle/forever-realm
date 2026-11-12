-- Scripts of the Tome spells (066): spell_bonus_tome_talent grants a talent point (cs_talentgrant.cpp), spell_bonus_tome_stat
-- +1 of the Tome's stat (cs_bonusstats.cpp). Apply to the `world` database; restart worldserver.
DELETE FROM spell_script_names WHERE spell_id BETWEEN 8104001 AND 8104018;
INSERT INTO spell_script_names (spell_id, ScriptName) VALUES
  (8104001, 'spell_bonus_tome_talent'),
  (8104002, 'spell_bonus_tome_stat'), (8104003, 'spell_bonus_tome_stat'), (8104004, 'spell_bonus_tome_stat'),
  (8104005, 'spell_bonus_tome_stat'), (8104006, 'spell_bonus_tome_stat'), (8104007, 'spell_bonus_tome_stat'),
  (8104008, 'spell_bonus_tome_stat'), (8104009, 'spell_bonus_tome_stat'), (8104010, 'spell_bonus_tome_stat'),
  (8104011, 'spell_bonus_tome_stat'), (8104012, 'spell_bonus_tome_stat'), (8104013, 'spell_bonus_tome_stat'),
  (8104014, 'spell_bonus_tome_stat'), (8104015, 'spell_bonus_tome_stat'), (8104016, 'spell_bonus_tome_stat'),
  (8104017, 'spell_bonus_tome_stat'), (8104018, 'spell_bonus_tome_stat');
