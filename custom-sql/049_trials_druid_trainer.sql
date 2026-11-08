-- Druid trainer in the Valley of Trials for orc and troll druids, copied from Corwin Oakheart (8103011: starting druid
-- list 1233, menu 4688, greetings readable by all), with an orc appearance (Krunn's, Razor Hill) and the Orgrimmar
-- faction (29, as Frang). Spawned where Sarah stood, just outside the camp; spawn settings from Frang (guid 20007651).
-- Apply to the `world` database; restart worldserver.
DELETE FROM creature WHERE guid = 26300027;
DELETE FROM creature_trainer WHERE CreatureID = 8103026;
DELETE FROM creature_template_gossip WHERE CreatureID = 8103026;
DELETE FROM creature_equip_template WHERE CreatureID = 8103026;
DELETE FROM creature_template_difficulty WHERE Entry = 8103026;
DELETE FROM creature_template_model WHERE CreatureID = 8103026;
DELETE FROM creature_template WHERE entry = 8103026;

DROP TEMPORARY TABLE IF EXISTS tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template WHERE entry = 8103011;
UPDATE tmp_clone SET entry = 8103026, name = 'Thrag Earthroot', faction = 29;
INSERT INTO creature_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template_model WHERE CreatureID = 8103011;
UPDATE tmp_clone SET CreatureID = 8103026, CreatureDisplayID = 3748;
INSERT INTO creature_template_model SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template_difficulty WHERE Entry = 8103011;
UPDATE tmp_clone SET Entry = 8103026;
INSERT INTO creature_template_difficulty SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_equip_template WHERE CreatureID = 8103011;
UPDATE tmp_clone SET CreatureID = 8103026;
INSERT INTO creature_equip_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

INSERT INTO creature_template_gossip (CreatureID, MenuID, VerifiedBuild) VALUES (8103026, 4688, 0);
INSERT INTO creature_trainer (CreatureID, TrainerID, MenuID, OptionID) VALUES (8103026, 1233, 4688, 0);

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature WHERE guid = 20007651;
UPDATE tmp_clone SET guid = 26300027, id = 8103026, modelid = 0, zoneId = 0, areaId = 0, position_x = -571.169, position_y = -4293.24, position_z = 39.6084, orientation = 5.91715, ScriptName = '';
INSERT INTO creature SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

-- Korgath the Redeemed (8103001, 005-007), the valley's paladin trainer, had the capital list (29, spells to level 60);
-- give him the starting-zone one like the other starting trainers (28, to level 6). Durga Lightsworn in Orgrimmar keeps 29.
UPDATE creature_trainer SET TrainerID = 28 WHERE CreatureID = 8103001;
