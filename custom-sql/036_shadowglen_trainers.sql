-- Paladin, shaman, mage and warlock trainers in Shadowglen for night elves, each copied from a starting-zone trainer of
-- its class (spells up to level 6, its greetings), with a night elf appearance and the Darnassus faction (80):
--   8103014 Thalric Dawnleaf   paladin, from Brother Sammuel (925, list 28, menu 4663), looks like Athridas Bearmantle
--   8103015 Ilyran Stormbough  shaman,  from Brannoc Stormward (8103012, list 11, menu 4652), looks like Gilshalan Windwalker
--   8103016 Sylwen Starweaver  mage,    from Khelden Bremen (198, list 5, menu 4660), looks like Keina
--   8103017 Naeryth Duskshade  warlock, from Drusilla La Salle (459, list 13, menu 1503), looks like Dellylah
-- Spawned where Sarah stood; spawn settings from Alyissia (guid 20046178). Apply to the `world` database; restart worldserver.
DELETE FROM creature WHERE guid BETWEEN 26300015 AND 26300018;
DELETE FROM creature_trainer WHERE CreatureID BETWEEN 8103014 AND 8103017;
DELETE FROM creature_template_gossip WHERE CreatureID BETWEEN 8103014 AND 8103017;
DELETE FROM creature_equip_template WHERE CreatureID BETWEEN 8103014 AND 8103017;
DELETE FROM creature_template_difficulty WHERE Entry BETWEEN 8103014 AND 8103017;
DELETE FROM creature_template_model WHERE CreatureID BETWEEN 8103014 AND 8103017;
DELETE FROM creature_template WHERE entry BETWEEN 8103014 AND 8103017;

DROP TEMPORARY TABLE IF EXISTS tmp_src;
CREATE TEMPORARY TABLE tmp_src (src INT UNSIGNED, dst INT UNSIGNED, guid BIGINT UNSIGNED, name VARCHAR(100), display INT UNSIGNED,
    x FLOAT, y FLOAT, z FLOAT, o FLOAT);
INSERT INTO tmp_src VALUES
  (925,     8103014, 26300015, 'Thalric Dawnleaf',  1896, 10480.9, 805.945, 1322.75, 2.00945),
  (8103012, 8103015, 26300016, 'Ilyran Stormbough', 2458, 10400.4, 817.254, 1317.58, 2.98946),
  (198,     8103016, 26300017, 'Sylwen Starweaver', 1728, 10433.8, 771.294, 1322.67, 3.02191),
  (459,     8103017, 26300018, 'Naeryth Duskshade', 4861, 10419.6, 761.855, 1322.67, 1.33343);

DROP TEMPORARY TABLE IF EXISTS tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT t.* FROM creature_template t JOIN tmp_src s ON s.src = t.entry;
UPDATE tmp_clone c JOIN tmp_src s ON s.src = c.entry SET c.entry = s.dst, c.name = s.name, c.faction = 80,
    c.AIName = '', c.ScriptName = '', c.KillCredit1 = 0, c.KillCredit2 = 0;
INSERT INTO creature_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT m.* FROM creature_template_model m JOIN tmp_src s ON s.src = m.CreatureID WHERE m.Idx = 0;
UPDATE tmp_clone c JOIN tmp_src s ON s.src = c.CreatureID SET c.CreatureID = s.dst, c.CreatureDisplayID = s.display;
INSERT INTO creature_template_model SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT d.* FROM creature_template_difficulty d JOIN tmp_src s ON s.src = d.Entry;
UPDATE tmp_clone c JOIN tmp_src s ON s.src = c.Entry SET c.Entry = s.dst;
INSERT INTO creature_template_difficulty SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT e.* FROM creature_equip_template e JOIN tmp_src s ON s.src = e.CreatureID;
UPDATE tmp_clone c JOIN tmp_src s ON s.src = c.CreatureID SET c.CreatureID = s.dst;
INSERT INTO creature_equip_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

INSERT INTO creature_template_gossip (CreatureID, MenuID, VerifiedBuild)
SELECT s.dst, g.MenuID, 0 FROM creature_template_gossip g JOIN tmp_src s ON s.src = g.CreatureID;
INSERT INTO creature_trainer (CreatureID, TrainerID, MenuID, OptionID)
SELECT s.dst, t.TrainerID, t.MenuID, t.OptionID FROM creature_trainer t JOIN tmp_src s ON s.src = t.CreatureID;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature WHERE guid = 20046178;
INSERT INTO tmp_clone SELECT * FROM creature WHERE guid = 20046178;
INSERT INTO tmp_clone SELECT * FROM creature WHERE guid = 20046178;
INSERT INTO tmp_clone SELECT * FROM creature WHERE guid = 20046178;
SET @n = 26300014;
UPDATE tmp_clone SET guid = (@n := @n + 1);
UPDATE tmp_clone c JOIN tmp_src s ON s.guid = c.guid SET c.id = s.dst, c.modelid = 0, c.zoneId = 0, c.areaId = 0,
    c.position_x = s.x, c.position_y = s.y, c.position_z = s.z, c.orientation = s.o, c.ScriptName = '';
INSERT INTO creature SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;
DROP TEMPORARY TABLE tmp_src;
