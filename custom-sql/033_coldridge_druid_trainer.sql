-- Druid trainer in Anvilmar (Coldridge Valley) for dwarf and gnome druids, copied from Corwin Oakheart (8103011, 027/031:
-- starting druid list 1233, menu 4688) with a dwarf appearance (Thamner Pol's) and the Ironforge faction.
-- Apply to the `world` database. Takes effect after a worldserver restart.
DELETE FROM creature WHERE guid = 26300014;
DELETE FROM creature_trainer WHERE CreatureID = 8103013;
DELETE FROM creature_template_gossip WHERE CreatureID = 8103013;
DELETE FROM creature_equip_template WHERE CreatureID = 8103013;
DELETE FROM creature_template_difficulty WHERE Entry = 8103013;
DELETE FROM creature_template_model WHERE CreatureID = 8103013;
DELETE FROM creature_template WHERE entry = 8103013;

DROP TEMPORARY TABLE IF EXISTS tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template WHERE entry = 8103011;
UPDATE tmp_clone SET entry = 8103013, name = 'Durgan Mossbeard', faction = 55;
INSERT INTO creature_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template_model WHERE CreatureID = 8103011;
UPDATE tmp_clone SET CreatureID = 8103013, CreatureDisplayID = 3433;
INSERT INTO creature_template_model SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template_difficulty WHERE Entry = 8103011;
UPDATE tmp_clone SET Entry = 8103013;
INSERT INTO creature_template_difficulty SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_equip_template WHERE CreatureID = 8103011;
UPDATE tmp_clone SET CreatureID = 8103013;
INSERT INTO creature_equip_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

INSERT INTO creature_template_gossip (CreatureID, MenuID, VerifiedBuild) VALUES (8103013, 4688, 0);
INSERT INTO creature_trainer (CreatureID, TrainerID, MenuID, OptionID) VALUES (8103013, 1233, 4688, 0);

-- Where Sarah stood in Anvilmar. The spawn settings come from Thran Khorman, Anvilmar's warrior trainer.
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature WHERE guid = 20000406;
UPDATE tmp_clone SET guid = 26300014, id = 8103013, modelid = 0, zoneId = 0, areaId = 0, position_x = -6086.38, position_y = 376.415, position_z = 395.542, orientation = 2.50852, ScriptName = '';
INSERT INTO creature SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;
