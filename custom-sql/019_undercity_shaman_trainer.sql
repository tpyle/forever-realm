-- Horde shaman trainer in Undercity, copied from Sagorne Creststrider (city shaman trainer, creature 13417).
-- Apply to the `world` database. Takes effect after a worldserver restart.
DELETE FROM creature WHERE guid = 26300010;
DELETE FROM creature_trainer WHERE CreatureID = 8103009;
DELETE FROM creature_template_gossip WHERE CreatureID = 8103009;
DELETE FROM creature_equip_template WHERE CreatureID = 8103009;
DELETE FROM creature_template_difficulty WHERE Entry = 8103009;
DELETE FROM creature_template_model WHERE CreatureID = 8103009;
DELETE FROM creature_template WHERE entry = 8103009;

DROP TEMPORARY TABLE IF EXISTS tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template WHERE entry = 13417;
UPDATE tmp_clone SET entry = 8103009, name = 'Morwen Gravecaller', subname = 'Shaman Trainer', faction = 68, trainer_class = 7, AIName = '', ScriptName = '', KillCredit1 = 0, KillCredit2 = 0;
INSERT INTO creature_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template_model WHERE CreatureID = 13417;
UPDATE tmp_clone SET CreatureID = 8103009, CreatureDisplayID = 2617;
INSERT INTO creature_template_model SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template_difficulty WHERE Entry = 13417;
UPDATE tmp_clone SET Entry = 8103009;
INSERT INTO creature_template_difficulty SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_equip_template WHERE CreatureID = 13417;
UPDATE tmp_clone SET CreatureID = 8103009;
INSERT INTO creature_equip_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

INSERT INTO creature_template_gossip (CreatureID, MenuID, VerifiedBuild) VALUES (8103009, 5123, 0);
INSERT INTO creature_trainer (CreatureID, TrainerID, MenuID, OptionID) VALUES (8103009, 10, 5123, 0);

-- Where Test stood in Undercity. The spawn settings come from Kaelystia Hatebringer, an Undercity trainer.
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature WHERE guid = 20031869;
UPDATE tmp_clone SET guid = 26300010, id = 8103009, modelid = 0, zoneId = 0, areaId = 0, position_x = 1693.7, position_y = 149.004, position_z = -60.4671, orientation = 2.79342, ScriptName = '';
INSERT INTO creature SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;
