-- Alliance shaman trainer in Stormwind, copied from Sagorne Creststrider (city shaman trainer, creature 13417).
-- Apply to the `world` database. Takes effect after a worldserver restart.
DELETE FROM creature WHERE guid = 26300005;
DELETE FROM creature_trainer WHERE CreatureID = 8103004;
DELETE FROM creature_template_gossip WHERE CreatureID = 8103004;
DELETE FROM creature_equip_template WHERE CreatureID = 8103004;
DELETE FROM creature_template_difficulty WHERE Entry = 8103004;
DELETE FROM creature_template_model WHERE CreatureID = 8103004;
DELETE FROM creature_template WHERE entry = 8103004;

DROP TEMPORARY TABLE IF EXISTS tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template WHERE entry = 13417;
UPDATE tmp_clone SET entry = 8103004, name = 'Rowan Stormcaller', subname = 'Shaman Trainer', faction = 12, trainer_class = 7, AIName = '', ScriptName = '', KillCredit1 = 0, KillCredit2 = 0;
INSERT INTO creature_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template_model WHERE CreatureID = 13417;
UPDATE tmp_clone SET CreatureID = 8103004, CreatureDisplayID = 1500;
INSERT INTO creature_template_model SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template_difficulty WHERE Entry = 13417;
UPDATE tmp_clone SET Entry = 8103004;
INSERT INTO creature_template_difficulty SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_equip_template WHERE CreatureID = 13417;
UPDATE tmp_clone SET CreatureID = 8103004;
INSERT INTO creature_equip_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

INSERT INTO creature_template_gossip (CreatureID, MenuID, VerifiedBuild) VALUES (8103004, 5123, 0);
INSERT INTO creature_trainer (CreatureID, TrainerID, MenuID, OptionID) VALUES (8103004, 10, 5123, 0);

-- Where Sarah stood in Stormwind. The spawn settings come from Wu Shen, a Stormwind trainer.
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature WHERE guid = 20079779;
UPDATE tmp_clone SET guid = 26300005, id = 8103004, modelid = 0, zoneId = 0, areaId = 0, position_x = -8780.8, position_y = 1085.11, position_z = 92.5197, orientation = 0.404635, ScriptName = '';
INSERT INTO creature SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;
