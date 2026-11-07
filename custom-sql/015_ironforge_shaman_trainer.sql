-- Alliance shaman trainer in Ironforge, copied from Sagorne Creststrider (city shaman trainer, creature 13417).
-- Apply to the `world` database. Takes effect after a worldserver restart.
DELETE FROM creature WHERE guid = 26300006;
DELETE FROM creature_trainer WHERE CreatureID = 8103005;
DELETE FROM creature_template_gossip WHERE CreatureID = 8103005;
DELETE FROM creature_equip_template WHERE CreatureID = 8103005;
DELETE FROM creature_template_difficulty WHERE Entry = 8103005;
DELETE FROM creature_template_model WHERE CreatureID = 8103005;
DELETE FROM creature_template WHERE entry = 8103005;

DROP TEMPORARY TABLE IF EXISTS tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template WHERE entry = 13417;
UPDATE tmp_clone SET entry = 8103005, name = 'Korrin Stonecaller', subname = 'Shaman Trainer', faction = 55, trainer_class = 7, AIName = '', ScriptName = '', KillCredit1 = 0, KillCredit2 = 0;
INSERT INTO creature_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template_model WHERE CreatureID = 13417;
UPDATE tmp_clone SET CreatureID = 8103005, CreatureDisplayID = 3092;
INSERT INTO creature_template_model SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template_difficulty WHERE Entry = 13417;
UPDATE tmp_clone SET Entry = 8103005;
INSERT INTO creature_template_difficulty SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_equip_template WHERE CreatureID = 13417;
UPDATE tmp_clone SET CreatureID = 8103005;
INSERT INTO creature_equip_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

INSERT INTO creature_template_gossip (CreatureID, MenuID, VerifiedBuild) VALUES (8103005, 5123, 0);
INSERT INTO creature_trainer (CreatureID, TrainerID, MenuID, OptionID) VALUES (8103005, 10, 5123, 0);

-- Where Sarah stood in Ironforge. The spawn settings come from Kelstrum Stonebreaker, an Ironforge trainer.
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature WHERE guid = 20000083;
UPDATE tmp_clone SET guid = 26300006, id = 8103005, modelid = 0, zoneId = 0, areaId = 0, position_x = -4709.32, position_y = -871.955, position_z = 501.958, orientation = 4.94004, ScriptName = '';
INSERT INTO creature SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;
