-- Horde paladin trainer in Undercity, copied from Lord Grayson Shadowbreaker (creature 928).
-- Apply to the `world` database. Takes effect after a worldserver restart.
DELETE FROM creature WHERE guid = 26300011;
DELETE FROM creature_trainer WHERE CreatureID = 8103010;
DELETE FROM creature_template_gossip WHERE CreatureID = 8103010;
DELETE FROM creature_equip_template WHERE CreatureID = 8103010;
DELETE FROM creature_template_difficulty WHERE Entry = 8103010;
DELETE FROM creature_template_model WHERE CreatureID = 8103010;
DELETE FROM creature_template WHERE entry = 8103010;

DROP TEMPORARY TABLE IF EXISTS tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template WHERE entry = 928;
UPDATE tmp_clone SET entry = 8103010, name = 'Alric Ashward', subname = 'Paladin Trainer', faction = 68, trainer_class = 2, AIName = '', ScriptName = '', KillCredit1 = 0, KillCredit2 = 0;
INSERT INTO creature_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template_model WHERE CreatureID = 928;
UPDATE tmp_clone SET CreatureID = 8103010, CreatureDisplayID = 4993;
INSERT INTO creature_template_model SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template_difficulty WHERE Entry = 928;
UPDATE tmp_clone SET Entry = 8103010;
INSERT INTO creature_template_difficulty SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_equip_template WHERE CreatureID = 928;
UPDATE tmp_clone SET CreatureID = 8103010;
INSERT INTO creature_equip_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

INSERT INTO creature_template_gossip (CreatureID, MenuID, VerifiedBuild) VALUES (8103010, 4663, 0);
INSERT INTO creature_trainer (CreatureID, TrainerID, MenuID, OptionID) VALUES (8103010, 29, 4663, 0);

-- Where Test stood in Undercity. The spawn settings come from Kaelystia Hatebringer, an Undercity trainer.
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature WHERE guid = 20031869;
UPDATE tmp_clone SET guid = 26300011, id = 8103010, modelid = 0, zoneId = 0, areaId = 0, position_x = 1724.38, position_y = 305.93, position_z = -61.5213, orientation = 3.58448, ScriptName = '';
INSERT INTO creature SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;
