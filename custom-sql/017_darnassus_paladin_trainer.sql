-- Alliance paladin trainer in Darnassus, copied from Lord Grayson Shadowbreaker (creature 928).
-- Apply to the `world` database. Takes effect after a worldserver restart.
DELETE FROM creature WHERE guid = 26300008;
DELETE FROM creature_trainer WHERE CreatureID = 8103007;
DELETE FROM creature_template_gossip WHERE CreatureID = 8103007;
DELETE FROM creature_equip_template WHERE CreatureID = 8103007;
DELETE FROM creature_template_difficulty WHERE Entry = 8103007;
DELETE FROM creature_template_model WHERE CreatureID = 8103007;
DELETE FROM creature_template WHERE entry = 8103007;

DROP TEMPORARY TABLE IF EXISTS tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template WHERE entry = 928;
UPDATE tmp_clone SET entry = 8103007, name = 'Selen Dawnward', subname = 'Paladin Trainer', faction = 80, trainer_class = 2, AIName = '', ScriptName = '', KillCredit1 = 0, KillCredit2 = 0;
INSERT INTO creature_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template_model WHERE CreatureID = 928;
UPDATE tmp_clone SET CreatureID = 8103007, CreatureDisplayID = 2229;
INSERT INTO creature_template_model SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template_difficulty WHERE Entry = 928;
UPDATE tmp_clone SET Entry = 8103007;
INSERT INTO creature_template_difficulty SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_equip_template WHERE CreatureID = 928;
UPDATE tmp_clone SET CreatureID = 8103007;
INSERT INTO creature_equip_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

INSERT INTO creature_template_gossip (CreatureID, MenuID, VerifiedBuild) VALUES (8103007, 4663, 0);
INSERT INTO creature_trainer (CreatureID, TrainerID, MenuID, OptionID) VALUES (8103007, 29, 4663, 0);

-- Where Sarah stood in Darnassus. The spawn settings come from Jocaste, a Darnassus trainer.
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature WHERE guid = 20046221;
UPDATE tmp_clone SET guid = 26300008, id = 8103007, modelid = 0, zoneId = 0, areaId = 0, position_x = 9977.05, position_y = 2290.31, position_z = 1341.39, orientation = 3.9021, ScriptName = '';
INSERT INTO creature SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;
