-- Shaman trainer in Northshire Abbey for human shamans, copied from Rowan Stormcaller (creature 8103004, Stormwind;
-- shaman trainer list 10), with a human appearance (Renato Gallina's). Apply to the `world` database; restart worldserver.
DELETE FROM creature WHERE guid = 26300013;
DELETE FROM creature_trainer WHERE CreatureID = 8103012;
DELETE FROM creature_template_gossip WHERE CreatureID = 8103012;
DELETE FROM creature_equip_template WHERE CreatureID = 8103012;
DELETE FROM creature_template_difficulty WHERE Entry = 8103012;
DELETE FROM creature_template_model WHERE CreatureID = 8103012;
DELETE FROM creature_template WHERE entry = 8103012;

DROP TEMPORARY TABLE IF EXISTS tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template WHERE entry = 8103004;
UPDATE tmp_clone SET entry = 8103012, name = 'Brannoc Stormward', subname = 'Shaman Trainer', faction = 12, trainer_class = 7, AIName = '', ScriptName = '', KillCredit1 = 0, KillCredit2 = 0;
INSERT INTO creature_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template_model WHERE CreatureID = 8103004;
UPDATE tmp_clone SET CreatureID = 8103012, CreatureDisplayID = 5074;
INSERT INTO creature_template_model SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template_difficulty WHERE Entry = 8103004;
UPDATE tmp_clone SET Entry = 8103012;
INSERT INTO creature_template_difficulty SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_equip_template WHERE CreatureID = 8103004;
UPDATE tmp_clone SET CreatureID = 8103012;
INSERT INTO creature_equip_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

INSERT INTO creature_template_gossip (CreatureID, MenuID, VerifiedBuild) VALUES (8103012, 5123, 0);
INSERT INTO creature_trainer (CreatureID, TrainerID, MenuID, OptionID) VALUES (8103012, 10, 5123, 0);

-- Where Sarah stood in Northshire Abbey. The spawn settings come from Brother Sammuel, the abbey's paladin trainer.
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature WHERE guid = 20079967;
UPDATE tmp_clone SET guid = 26300013, id = 8103012, modelid = 0, zoneId = 0, areaId = 0, position_x = -8888.03, position_y = -225.495, position_z = 81.0777, orientation = 5.79186, ScriptName = '';
INSERT INTO creature SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;
