-- Hunter, shaman and druid trainers in Deathknell for undead, each copied from a starting-zone trainer of its class
-- (spells up to level 6, its greetings), with an undead appearance from a Brill NPC and the Undercity faction (68):
--   8103018 Edric Thornwood  hunter, from Thorgas Grimson (895, list 19, menu 4675), looks like Sahvan Bloodshadow
--   8103019 Mordecai Vale    shaman, from Brannoc Stormward (8103012, list 11, menu 4652), looks like Thomas Arlento
--   8103020 Agatha Fenwick   druid,  from Corwin Oakheart (8103011, list 1233, menu 4688), looks like Doreen Beltis
-- Spawned where Sarah stood; spawn settings from Dannal Stern (guid 20028464). Apply to the `world` database;
-- restart worldserver.
DELETE FROM creature WHERE guid BETWEEN 26300019 AND 26300021;
DELETE FROM creature_trainer WHERE CreatureID BETWEEN 8103018 AND 8103020;
DELETE FROM creature_template_gossip WHERE CreatureID BETWEEN 8103018 AND 8103020;
DELETE FROM creature_equip_template WHERE CreatureID BETWEEN 8103018 AND 8103020;
DELETE FROM creature_template_difficulty WHERE Entry BETWEEN 8103018 AND 8103020;
DELETE FROM creature_template_model WHERE CreatureID BETWEEN 8103018 AND 8103020;
DELETE FROM creature_template WHERE entry BETWEEN 8103018 AND 8103020;

DROP TEMPORARY TABLE IF EXISTS tmp_src;
CREATE TEMPORARY TABLE tmp_src (src INT UNSIGNED, dst INT UNSIGNED, guid BIGINT UNSIGNED, name VARCHAR(100), display INT UNSIGNED,
    x FLOAT, y FLOAT, z FLOAT, o FLOAT);
INSERT INTO tmp_src VALUES
  (895,     8103018, 26300019, 'Edric Thornwood', 3521, 1863.83, 1568.59, 99.0629, 2.30905),
  (8103012, 8103019, 26300020, 'Mordecai Vale',   3533, 1899.04, 1631.24, 93.3265, 0.390158),
  (8103011, 8103020, 26300021, 'Agatha Fenwick',  3529, 1862.01, 1612.08, 95.6068, 4.61639);

DROP TEMPORARY TABLE IF EXISTS tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT t.* FROM creature_template t JOIN tmp_src s ON s.src = t.entry;
UPDATE tmp_clone c JOIN tmp_src s ON s.src = c.entry SET c.entry = s.dst, c.name = s.name, c.faction = 68,
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

-- Thorgas's greetings are in a dwarf accent; use Lanka Farshot's neutral hunter menu (same list 19).
UPDATE creature_template_gossip SET MenuID = 4647 WHERE CreatureID = 8103018;
UPDATE creature_trainer ct JOIN creature_trainer l ON l.CreatureID = 3061 SET ct.MenuID = l.MenuID, ct.OptionID = l.OptionID
    WHERE ct.CreatureID = 8103018;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature WHERE guid = 20028464;
INSERT INTO tmp_clone SELECT * FROM creature WHERE guid = 20028464;
INSERT INTO tmp_clone SELECT * FROM creature WHERE guid = 20028464;
SET @n = 26300018;
UPDATE tmp_clone SET guid = (@n := @n + 1);
UPDATE tmp_clone c JOIN tmp_src s ON s.guid = c.guid SET c.id = s.dst, c.modelid = 0, c.zoneId = 0, c.areaId = 0,
    c.position_x = s.x, c.position_y = s.y, c.position_z = s.z, c.orientation = s.o, c.ScriptName = '';
INSERT INTO creature SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;
DROP TEMPORARY TABLE tmp_src;
