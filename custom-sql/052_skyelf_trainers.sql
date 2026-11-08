-- Paladin, priest and warlock trainers at the Sky Elf start (Thendal Grove, map 2991), shared by both Sky Elf races,
-- each copied from a starting-zone trainer of its class (spells up to level 6), with a Sky Elf appearance from a later
-- hub and the neutral faction (35) the zone's other trainers use:
--   8103027 Saraan Brightgale  paladin, from Brother Sammuel (925, list 28, menu 4663), looks like Valennia Stormfist
--   8103028 Liaara Moonbreeze  priest,  from Branstock Khalder (837, list 7), looks like Sania Silverstream
--   8103029 Vexaan Duskgale    warlock, from Drusilla La Salle (459, list 13), looks like Danarii Bellowveil
-- Spawned where Sarah stood; spawn settings from Blademaster Ren (guid 21100922).
-- No stock priest or warlock greeting is readable by both factions (each is in Common or Orcish), so those two get
-- their own menus: one universal text (npc_text 8591 and 2175) and the options of menus 4679 and 1503 with their
-- conditions, under new GossipOptionIDs.
-- The zone's shaman trainers (Windshaper Boro, Sessaria Skystride, Aarnor Galestrike: Windshapers, 3599) and its mage
-- trainer (Dorii Brightwhisper: High Order, 3600) were hostile to the other faction's Sky Elves; they become neutral.
-- Apply to the `world` database; restart worldserver.
DELETE FROM creature WHERE guid BETWEEN 26300028 AND 26300030;
DELETE FROM creature_trainer WHERE CreatureID BETWEEN 8103027 AND 8103029;
DELETE FROM creature_template_gossip WHERE CreatureID BETWEEN 8103027 AND 8103029;
DELETE FROM creature_equip_template WHERE CreatureID BETWEEN 8103027 AND 8103029;
DELETE FROM creature_template_difficulty WHERE Entry BETWEEN 8103027 AND 8103029;
DELETE FROM creature_template_model WHERE CreatureID BETWEEN 8103027 AND 8103029;
DELETE FROM creature_template WHERE entry BETWEEN 8103027 AND 8103029;
DELETE FROM conditions WHERE SourceTypeOrReferenceId = 15 AND SourceGroup IN (8103028, 8103029);
DELETE FROM gossip_menu_option WHERE MenuID IN (8103028, 8103029);
DELETE FROM gossip_menu WHERE MenuID IN (8103028, 8103029);

DROP TEMPORARY TABLE IF EXISTS tmp_src;
CREATE TEMPORARY TABLE tmp_src (src INT UNSIGNED, dst INT UNSIGNED, guid BIGINT UNSIGNED, name VARCHAR(100), display INT UNSIGNED,
    x FLOAT, y FLOAT, z FLOAT, o FLOAT);
INSERT INTO tmp_src VALUES
  (925, 8103027, 26300028, 'Saraan Brightgale', 137871, 4073.25, 1834.7,  977.742, 1.64272),
  (837, 8103028, 26300029, 'Liaara Moonbreeze', 138143, 4133.61, 1866.84, 975.53,  3.55607),
  (459, 8103029, 26300030, 'Vexaan Duskgale',   138150, 4109.46, 1789.05, 988.631, 5.30189);

DROP TEMPORARY TABLE IF EXISTS tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT t.* FROM creature_template t JOIN tmp_src s ON s.src = t.entry;
UPDATE tmp_clone c JOIN tmp_src s ON s.src = c.entry SET c.entry = s.dst, c.name = s.name, c.faction = 35,
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

-- Universal menus for the priest and the warlock.
INSERT INTO gossip_menu (MenuID, TextID, VerifiedBuild) VALUES (8103028, 8591, 0), (8103029, 2175, 0);
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM gossip_menu_option WHERE MenuID IN (4679, 1503);
UPDATE tmp_clone SET MenuID = IF(MenuID = 4679, 8103028, 8103029);
UPDATE tmp_clone SET GossipOptionID = 810300000 + (MenuID - 8103000) * 10 + OptionID;
INSERT INTO gossip_menu_option SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM conditions WHERE SourceTypeOrReferenceId = 15 AND SourceGroup IN (4679, 1503);
UPDATE tmp_clone SET SourceGroup = IF(SourceGroup = 4679, 8103028, 8103029), Comment = 'Sky Elf trainer menu (052)';
INSERT INTO conditions SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

INSERT INTO creature_template_gossip (CreatureID, MenuID, VerifiedBuild) VALUES (8103027, 4663, 0), (8103028, 8103028, 0), (8103029, 8103029, 0);
INSERT INTO creature_trainer (CreatureID, TrainerID, MenuID, OptionID) VALUES (8103027, 28, 4663, 0), (8103028, 7, 8103028, 0), (8103029, 13, 8103029, 0);

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature WHERE guid = 21100922;
INSERT INTO tmp_clone SELECT * FROM creature WHERE guid = 21100922;
INSERT INTO tmp_clone SELECT * FROM creature WHERE guid = 21100922;
SET @n = 26300027;
UPDATE tmp_clone SET guid = (@n := @n + 1);
UPDATE tmp_clone c JOIN tmp_src s ON s.guid = c.guid SET c.id = s.dst, c.modelid = 0, c.zoneId = 0, c.areaId = 0,
    c.position_x = s.x, c.position_y = s.y, c.position_z = s.z, c.orientation = s.o, c.ScriptName = '';
INSERT INTO creature SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;
DROP TEMPORARY TABLE tmp_src;

UPDATE creature_template SET faction = 35 WHERE entry IN (251374, 252382, 254082, 251379);
