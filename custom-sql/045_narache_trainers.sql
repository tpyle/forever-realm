-- Paladin, rogue, priest, mage and warlock trainers in Camp Narache for tauren, each copied from a starting-zone trainer
-- of its class with neutral greetings (spells up to level 6), with a tauren appearance from a Bloodhoof Village NPC and
-- the Thunder Bluff faction (104, as the camp's trainers):
--   8103021 Ahrok Dawnhoof     paladin, from Brother Sammuel (925, list 28, menu 4663), looks like Harant Ironbrace
--   8103022 Kesh Swiftstride   rogue,   from Frahun Shadewhisper (3594, list 25, menu 4690), looks like Ruul Eagletalon
--   8103023 Yanna Brightmane   priest,  from Branstock Khalder (837, list 7, menu 4679), looks like Wunna Darkmane
--   8103024 Tarhi Starhorn     mage,    from Khelden Bremen (198, list 5, menu 4660), looks like Kennah Hawkseye
--   8103025 Grath Ashmane      warlock, from Drusilla La Salle (459, list 13, menu 1503), looks like Magrin Rivermane
-- Spawned where Sarah stood; spawn settings from Harutt Thunderhorn (guid 20026897). Apply to the `world` database;
-- restart worldserver.
DELETE FROM creature WHERE guid BETWEEN 26300022 AND 26300026;
DELETE FROM creature_trainer WHERE CreatureID BETWEEN 8103021 AND 8103025;
DELETE FROM creature_template_gossip WHERE CreatureID BETWEEN 8103021 AND 8103025;
DELETE FROM creature_equip_template WHERE CreatureID BETWEEN 8103021 AND 8103025;
DELETE FROM creature_template_difficulty WHERE Entry BETWEEN 8103021 AND 8103025;
DELETE FROM creature_template_model WHERE CreatureID BETWEEN 8103021 AND 8103025;
DELETE FROM creature_template WHERE entry BETWEEN 8103021 AND 8103025;

DROP TEMPORARY TABLE IF EXISTS tmp_src;
CREATE TEMPORARY TABLE tmp_src (src INT UNSIGNED, dst INT UNSIGNED, guid BIGINT UNSIGNED, name VARCHAR(100), display INT UNSIGNED,
    x FLOAT, y FLOAT, z FLOAT, o FLOAT);
INSERT INTO tmp_src VALUES
  (925,  8103021, 26300022, 'Ahrok Dawnhoof',   3804, -2908.42, -274.823, 53.9134, 1.37634),
  (3594, 8103022, 26300023, 'Kesh Swiftstride', 3822, -2850.4,  -253.823, 53.9174, 3.14407),
  (837,  8103023, 26300024, 'Yanna Brightmane', 3806, -2896.74, -325.341, 58.3273, 4.67825),
  (198,  8103024, 26300025, 'Tarhi Starhorn',   3803, -3035.63, -201.57,  60.6324, 6.27202),
  (459,  8103025, 26300026, 'Grath Ashmane',    5507, -2952.79, -131.49,  70.3974, 1.97255);

DROP TEMPORARY TABLE IF EXISTS tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT t.* FROM creature_template t JOIN tmp_src s ON s.src = t.entry;
UPDATE tmp_clone c JOIN tmp_src s ON s.src = c.entry SET c.entry = s.dst, c.name = s.name, c.faction = 104,
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

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature WHERE guid = 20026897;
INSERT INTO tmp_clone SELECT * FROM creature WHERE guid = 20026897;
INSERT INTO tmp_clone SELECT * FROM creature WHERE guid = 20026897;
INSERT INTO tmp_clone SELECT * FROM creature WHERE guid = 20026897;
INSERT INTO tmp_clone SELECT * FROM creature WHERE guid = 20026897;
SET @n = 26300021;
UPDATE tmp_clone SET guid = (@n := @n + 1);
UPDATE tmp_clone c JOIN tmp_src s ON s.guid = c.guid SET c.id = s.dst, c.modelid = 0, c.zoneId = 0, c.areaId = 0,
    c.position_x = s.x, c.position_y = s.y, c.position_z = s.z, c.orientation = s.o, c.ScriptName = '';
INSERT INTO creature SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;
DROP TEMPORARY TABLE tmp_src;
