-- Fizzle Everhand, who teaches professions through npc_profession_tutor. Apply to the `world` database.
-- Faction 35 is friendly to everyone. Needs a worldserver built with that script.
DELETE FROM creature WHERE guid IN (26300003, 26300004);
DELETE FROM creature_template_difficulty WHERE Entry = 8103003;
DELETE FROM creature_template_model WHERE CreatureID = 8103003;
DELETE FROM creature_template WHERE entry = 8103003;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template WHERE entry = 3353;
UPDATE tmp_clone SET entry = 8103003, name = 'Fizzle Everhand', subname = 'Profession Tutor', faction = 35, npcflag = 1,
  trainer_class = 0, AIName = '', ScriptName = 'npc_profession_tutor', KillCredit1 = 0, KillCredit2 = 0;
INSERT INTO creature_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template_model WHERE CreatureID = 3353;
UPDATE tmp_clone SET CreatureID = 8103003, CreatureDisplayID = 7054;
INSERT INTO creature_template_model SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template_difficulty WHERE Entry = 3353;
UPDATE tmp_clone SET Entry = 8103003;
INSERT INTO creature_template_difficulty SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

-- Orgrimmar, beside Durga Lightsworn
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature WHERE guid = 26300002;
UPDATE tmp_clone SET guid = 26300003, id = 8103003, equipment_id = 0, position_x = 1978.52, position_y = -4797.59, ScriptName = '';
INSERT INTO creature SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

-- Northshire, beside Brother Sammuel
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature WHERE guid = 20079967;
UPDATE tmp_clone SET guid = 26300004, id = 8103003, equipment_id = 0, position_x = -8911.70, position_y = -214.52, ScriptName = '';
INSERT INTO creature SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;
