-- Alliance shaman trainer in Darnassus, copied from Sagorne Creststrider (city shaman trainer, creature 13417).
-- Apply to the `world` database. Takes effect after a worldserver restart.
DELETE FROM creature WHERE guid = 26300007;
DELETE FROM creature_trainer WHERE CreatureID = 8103006;
DELETE FROM creature_template_gossip WHERE CreatureID = 8103006;
DELETE FROM creature_equip_template WHERE CreatureID = 8103006;
DELETE FROM creature_template_difficulty WHERE Entry = 8103006;
DELETE FROM creature_template_model WHERE CreatureID = 8103006;
DELETE FROM creature_template WHERE entry = 8103006;

DROP TEMPORARY TABLE IF EXISTS tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template WHERE entry = 13417;
UPDATE tmp_clone SET entry = 8103006, name = 'Aerin Windcaller', subname = 'Shaman Trainer', faction = 80, trainer_class = 7, AIName = '', ScriptName = '', KillCredit1 = 0, KillCredit2 = 0;
INSERT INTO creature_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template_model WHERE CreatureID = 13417;
UPDATE tmp_clone SET CreatureID = 8103006, CreatureDisplayID = 2198;
INSERT INTO creature_template_model SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template_difficulty WHERE Entry = 13417;
UPDATE tmp_clone SET Entry = 8103006;
INSERT INTO creature_template_difficulty SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_equip_template WHERE CreatureID = 13417;
UPDATE tmp_clone SET CreatureID = 8103006;
INSERT INTO creature_equip_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

INSERT INTO creature_template_gossip (CreatureID, MenuID, VerifiedBuild) VALUES (8103006, 5123, 0);
INSERT INTO creature_trainer (CreatureID, TrainerID, MenuID, OptionID) VALUES (8103006, 10, 5123, 0);

-- Where Sarah stood in Darnassus. The spawn settings come from Jocaste, a Darnassus trainer.
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature WHERE guid = 20046221;
UPDATE tmp_clone SET guid = 26300007, id = 8103006, modelid = 0, zoneId = 0, areaId = 0, position_x = 9889.71, position_y = 2439.31, position_z = 1315.9, orientation = 2.96632, ScriptName = '';
INSERT INTO creature SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;
