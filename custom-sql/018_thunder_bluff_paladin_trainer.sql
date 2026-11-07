-- Horde paladin trainer in Thunder Bluff, copied from Lord Grayson Shadowbreaker (creature 928).
-- Apply to the `world` database. Takes effect after a worldserver restart.
DELETE FROM creature WHERE guid = 26300009;
DELETE FROM creature_trainer WHERE CreatureID = 8103008;
DELETE FROM creature_template_gossip WHERE CreatureID = 8103008;
DELETE FROM creature_equip_template WHERE CreatureID = 8103008;
DELETE FROM creature_template_difficulty WHERE Entry = 8103008;
DELETE FROM creature_template_model WHERE CreatureID = 8103008;
DELETE FROM creature_template WHERE entry = 8103008;

DROP TEMPORARY TABLE IF EXISTS tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template WHERE entry = 928;
UPDATE tmp_clone SET entry = 8103008, name = 'Tahna Sunhoof', subname = 'Paladin Trainer', faction = 104, trainer_class = 2, AIName = '', ScriptName = '', KillCredit1 = 0, KillCredit2 = 0;
INSERT INTO creature_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template_model WHERE CreatureID = 928;
UPDATE tmp_clone SET CreatureID = 8103008, CreatureDisplayID = 2091;
INSERT INTO creature_template_model SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template_difficulty WHERE Entry = 928;
UPDATE tmp_clone SET Entry = 8103008;
INSERT INTO creature_template_difficulty SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_equip_template WHERE CreatureID = 928;
UPDATE tmp_clone SET CreatureID = 8103008;
INSERT INTO creature_equip_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

INSERT INTO creature_template_gossip (CreatureID, MenuID, VerifiedBuild) VALUES (8103008, 4663, 0);
INSERT INTO creature_trainer (CreatureID, TrainerID, MenuID, OptionID) VALUES (8103008, 29, 4663, 0);

-- Where Test stood in Thunder Bluff. The spawn settings come from Siln Skychaser, a Thunder Bluff trainer.
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature WHERE guid = 20026656;
UPDATE tmp_clone SET guid = 26300009, id = 8103008, modelid = 0, zoneId = 0, areaId = 0, position_x = -1071.36, position_y = -284.591, position_z = 159.031, orientation = 6.1543, ScriptName = '';
INSERT INTO creature SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;
