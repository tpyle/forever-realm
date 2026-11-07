-- Horde paladin trainers, copied from existing orc warrior trainers. Apply to the `world` database.
-- Uses trainer list 29 (all paladin spells) and paladin gossip menu 4663.

-- Korgath the Redeemed, copied from creature 3153
DELETE FROM creature WHERE guid = 26300001;
DELETE FROM creature_trainer WHERE CreatureID = 8103001;
DELETE FROM creature_template_gossip WHERE CreatureID = 8103001;
DELETE FROM creature_equip_template WHERE CreatureID = 8103001;
DELETE FROM creature_template_difficulty WHERE Entry = 8103001;
DELETE FROM creature_template_model WHERE CreatureID = 8103001;
DELETE FROM creature_template WHERE entry = 8103001;
DROP TEMPORARY TABLE IF EXISTS tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template WHERE entry = 3153;
UPDATE tmp_clone SET entry = 8103001, name = 'Korgath the Redeemed', subname = 'Paladin Trainer', trainer_class = 2, AIName = '', ScriptName = '', KillCredit1 = 0, KillCredit2 = 0;
INSERT INTO creature_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template_model WHERE CreatureID = 3153;
UPDATE tmp_clone SET CreatureID = 8103001;
INSERT INTO creature_template_model SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template_difficulty WHERE Entry = 3153;
UPDATE tmp_clone SET Entry = 8103001;
INSERT INTO creature_template_difficulty SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_equip_template WHERE CreatureID = 3153;
UPDATE tmp_clone SET CreatureID = 8103001;
INSERT INTO creature_equip_template SELECT * FROM tmp_clone;
INSERT INTO creature_template_gossip (CreatureID, MenuID, VerifiedBuild) VALUES (8103001, 4663, 0);
INSERT INTO creature_trainer (CreatureID, TrainerID, MenuID, OptionID) VALUES (8103001, 29, 4663, 0);
DROP TEMPORARY TABLE tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature WHERE guid = 20007651;
UPDATE tmp_clone SET guid = 26300001, id = 8103001, position_x = -636.73, position_y = -4228.9, ScriptName = '';
INSERT INTO creature SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

-- Durga Lightsworn, copied from creature 3353
DELETE FROM creature WHERE guid = 26300002;
DELETE FROM creature_trainer WHERE CreatureID = 8103002;
DELETE FROM creature_template_gossip WHERE CreatureID = 8103002;
DELETE FROM creature_equip_template WHERE CreatureID = 8103002;
DELETE FROM creature_template_difficulty WHERE Entry = 8103002;
DELETE FROM creature_template_model WHERE CreatureID = 8103002;
DELETE FROM creature_template WHERE entry = 8103002;
DROP TEMPORARY TABLE IF EXISTS tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template WHERE entry = 3353;
UPDATE tmp_clone SET entry = 8103002, name = 'Durga Lightsworn', subname = 'Paladin Trainer', trainer_class = 2, AIName = '', ScriptName = '', KillCredit1 = 0, KillCredit2 = 0;
INSERT INTO creature_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template_model WHERE CreatureID = 3353;
UPDATE tmp_clone SET CreatureID = 8103002;
INSERT INTO creature_template_model SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_template_difficulty WHERE Entry = 3353;
UPDATE tmp_clone SET Entry = 8103002;
INSERT INTO creature_template_difficulty SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature_equip_template WHERE CreatureID = 3353;
UPDATE tmp_clone SET CreatureID = 8103002;
INSERT INTO creature_equip_template SELECT * FROM tmp_clone;
INSERT INTO creature_template_gossip (CreatureID, MenuID, VerifiedBuild) VALUES (8103002, 4663, 0);
INSERT INTO creature_trainer (CreatureID, TrainerID, MenuID, OptionID) VALUES (8103002, 29, 4663, 0);
DROP TEMPORARY TABLE tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature WHERE guid = 20007971;
UPDATE tmp_clone SET guid = 26300002, id = 8103002, position_x = 1982.79, position_y = -4798.89, ScriptName = '';
INSERT INTO creature SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;
