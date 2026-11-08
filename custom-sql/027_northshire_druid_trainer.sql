-- Druid trainer in Northshire Abbey for human druids, copied from Sheldras Moontree (creature 5504, Stormwind),
-- with a human appearance (Harlan Bagley's). Apply to the `world` database. Takes effect after a worldserver restart.
DELETE FROM creature WHERE guid = 26300012;
DELETE FROM creature_trainer WHERE CreatureID = 8103011;
DELETE FROM creature_template_gossip WHERE CreatureID = 8103011;
DELETE FROM creature_equip_template WHERE CreatureID = 8103011;
DELETE FROM creature_template_difficulty WHERE Entry = 8103011;
DELETE FROM creature_template_model WHERE CreatureID = 8103011;
DELETE FROM creature_template WHERE entry = 8103011;

DROP TEMPORARY TABLE IF EXISTS tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template WHERE entry = 5504;
UPDATE tmp_clone SET entry = 8103011, name = 'Corwin Oakheart', subname = 'Druid Trainer', faction = 12, trainer_class = 11, AIName = '', ScriptName = '', KillCredit1 = 0, KillCredit2 = 0;
INSERT INTO creature_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template_model WHERE CreatureID = 5504;
UPDATE tmp_clone SET CreatureID = 8103011, CreatureDisplayID = 5551;
INSERT INTO creature_template_model SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template_difficulty WHERE Entry = 5504;
UPDATE tmp_clone SET Entry = 8103011;
INSERT INTO creature_template_difficulty SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_equip_template WHERE CreatureID = 5504;
UPDATE tmp_clone SET CreatureID = 8103011;
INSERT INTO creature_equip_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

INSERT INTO creature_template_gossip (CreatureID, MenuID, VerifiedBuild) VALUES (8103011, 4508, 0);
INSERT INTO creature_trainer (CreatureID, TrainerID, MenuID, OptionID) VALUES (8103011, 17, 4508, 0);

-- Where Sarah stood in Northshire Abbey. The spawn settings come from Brother Sammuel, the abbey's paladin trainer.
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature WHERE guid = 20079967;
UPDATE tmp_clone SET guid = 26300012, id = 8103011, modelid = 0, zoneId = 0, areaId = 0, position_x = -8883.85, position_y = -222.625, position_z = 81.5489, orientation = 4.61665, ScriptName = '';
INSERT INTO creature SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;
