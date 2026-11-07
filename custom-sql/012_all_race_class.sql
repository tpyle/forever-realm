-- Unlocks every race/class combination on the server side. Generated; apply to the `world` database.
-- Takes effect after a worldserver restart. Needs 013_all_race_class_client_hotfix.sql for the client.

-- Every one of the 90 combinations, including undead paladin, which the client offers but the server lacked.
INSERT IGNORE INTO class_expansion_requirement (ClassID, RaceID, ActiveExpansionLevel, AccountExpansionLevel) VALUES
  (7, 1, 0, 0),
  (11, 1, 0, 0),
  (11, 2, 0, 0),
  (11, 3, 0, 0),
  (2, 4, 0, 0),
  (7, 4, 0, 0),
  (2, 5, 0, 0),
  (7, 5, 0, 0),
  (11, 5, 0, 0),
  (2, 7, 0, 0),
  (7, 7, 0, 0),
  (11, 7, 0, 0),
  (2, 8, 0, 0),
  (2, 95, 0, 0),
  (5, 95, 0, 0),
  (7, 95, 0, 0),
  (9, 95, 0, 0),
  (2, 96, 0, 0),
  (5, 96, 0, 0),
  (8, 96, 0, 0),
  (9, 96, 0, 0);

-- Starting locations come from the same race's warrior.
INSERT INTO playercreateinfo (race, class, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id)
  SELECT race, 2, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id FROM playercreateinfo WHERE race = 4 AND class = 1;
INSERT INTO playercreateinfo (race, class, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id)
  SELECT race, 2, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id FROM playercreateinfo WHERE race = 7 AND class = 1;
INSERT INTO playercreateinfo (race, class, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id)
  SELECT race, 2, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id FROM playercreateinfo WHERE race = 8 AND class = 1;
INSERT INTO playercreateinfo (race, class, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id)
  SELECT race, 2, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id FROM playercreateinfo WHERE race = 95 AND class = 1;
INSERT INTO playercreateinfo (race, class, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id)
  SELECT race, 2, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id FROM playercreateinfo WHERE race = 96 AND class = 1;
INSERT INTO playercreateinfo (race, class, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id)
  SELECT race, 5, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id FROM playercreateinfo WHERE race = 95 AND class = 1;
INSERT INTO playercreateinfo (race, class, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id)
  SELECT race, 5, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id FROM playercreateinfo WHERE race = 96 AND class = 1;
INSERT INTO playercreateinfo (race, class, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id)
  SELECT race, 7, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id FROM playercreateinfo WHERE race = 1 AND class = 1;
INSERT INTO playercreateinfo (race, class, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id)
  SELECT race, 7, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id FROM playercreateinfo WHERE race = 4 AND class = 1;
INSERT INTO playercreateinfo (race, class, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id)
  SELECT race, 7, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id FROM playercreateinfo WHERE race = 5 AND class = 1;
INSERT INTO playercreateinfo (race, class, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id)
  SELECT race, 7, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id FROM playercreateinfo WHERE race = 7 AND class = 1;
INSERT INTO playercreateinfo (race, class, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id)
  SELECT race, 7, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id FROM playercreateinfo WHERE race = 95 AND class = 1;
INSERT INTO playercreateinfo (race, class, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id)
  SELECT race, 8, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id FROM playercreateinfo WHERE race = 96 AND class = 1;
INSERT INTO playercreateinfo (race, class, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id)
  SELECT race, 9, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id FROM playercreateinfo WHERE race = 95 AND class = 1;
INSERT INTO playercreateinfo (race, class, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id)
  SELECT race, 9, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id FROM playercreateinfo WHERE race = 96 AND class = 1;
INSERT INTO playercreateinfo (race, class, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id)
  SELECT race, 11, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id FROM playercreateinfo WHERE race = 1 AND class = 1;
INSERT INTO playercreateinfo (race, class, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id)
  SELECT race, 11, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id FROM playercreateinfo WHERE race = 2 AND class = 1;
INSERT INTO playercreateinfo (race, class, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id)
  SELECT race, 11, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id FROM playercreateinfo WHERE race = 3 AND class = 1;
INSERT INTO playercreateinfo (race, class, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id)
  SELECT race, 11, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id FROM playercreateinfo WHERE race = 5 AND class = 1;
INSERT INTO playercreateinfo (race, class, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id)
  SELECT race, 11, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y, npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id FROM playercreateinfo WHERE race = 7 AND class = 1;

-- Action bars: Auto Attack, the class's starting spells, then the race's two abilities.
DELETE FROM playercreateinfo_action WHERE (race, class) IN ((4,2),(6,2),(7,2),(8,2),(95,2),(96,2),(5,3),(7,3),(6,4),(2,5),(6,5),(95,5),(96,5),(1,7),(4,7),(5,7),(7,7),(95,7),(3,8),(4,8),(6,8),(96,8),(3,9),(4,9),(6,9),(95,9),(96,9),(1,11),(2,11),(3,11),(5,11),(7,11),(8,11));
INSERT INTO playercreateinfo_action (race, class, button, action, type) VALUES
  (4, 2, 0, 6603, 0),
  (4, 2, 1, 20154, 0),
  (4, 2, 2, 635, 0),
  (4, 2, 8, 1259799, 0),
  (4, 2, 9, 20580, 0),
  (6, 2, 0, 6603, 0),
  (6, 2, 1, 20154, 0),
  (6, 2, 2, 635, 0),
  (6, 2, 8, 20549, 0),
  (6, 2, 9, 20552, 0),
  (7, 2, 0, 6603, 0),
  (7, 2, 1, 20154, 0),
  (7, 2, 2, 635, 0),
  (7, 2, 9, 20589, 0),
  (8, 2, 0, 6603, 0),
  (8, 2, 1, 20154, 0),
  (8, 2, 2, 635, 0),
  (8, 2, 8, 20554, 0),
  (8, 2, 9, 1260270, 0),
  (95, 2, 0, 6603, 0),
  (95, 2, 1, 20154, 0),
  (95, 2, 2, 635, 0),
  (95, 2, 8, 1259705, 0),
  (95, 2, 9, 1259416, 0),
  (96, 2, 0, 6603, 0),
  (96, 2, 1, 20154, 0),
  (96, 2, 2, 635, 0),
  (96, 2, 8, 1259686, 0),
  (96, 2, 9, 1259416, 0),
  (5, 3, 0, 6603, 0),
  (5, 3, 1, 2973, 0),
  (5, 3, 2, 75, 0),
  (5, 3, 8, 20577, 0),
  (5, 3, 9, 7744, 0),
  (7, 3, 0, 6603, 0),
  (7, 3, 1, 2973, 0),
  (7, 3, 2, 75, 0),
  (7, 3, 9, 20589, 0),
  (6, 4, 0, 6603, 0),
  (6, 4, 1, 1752, 0),
  (6, 4, 2, 2098, 0),
  (6, 4, 3, 2764, 0),
  (6, 4, 8, 20549, 0),
  (6, 4, 9, 20552, 0),
  (2, 5, 0, 6603, 0),
  (2, 5, 1, 585, 0),
  (2, 5, 2, 2050, 0),
  (2, 5, 9, 20572, 0),
  (6, 5, 0, 6603, 0),
  (6, 5, 1, 585, 0),
  (6, 5, 2, 2050, 0),
  (6, 5, 8, 20549, 0),
  (6, 5, 9, 20552, 0),
  (95, 5, 0, 6603, 0),
  (95, 5, 1, 585, 0),
  (95, 5, 2, 2050, 0),
  (95, 5, 8, 1259705, 0),
  (95, 5, 9, 1259416, 0),
  (96, 5, 0, 6603, 0),
  (96, 5, 1, 585, 0),
  (96, 5, 2, 2050, 0),
  (96, 5, 8, 1259686, 0),
  (96, 5, 9, 1259416, 0),
  (1, 7, 0, 6603, 0),
  (1, 7, 1, 403, 0),
  (1, 7, 2, 331, 0),
  (1, 7, 8, 1259718, 0),
  (1, 7, 9, 20600, 0),
  (4, 7, 0, 6603, 0),
  (4, 7, 1, 403, 0),
  (4, 7, 2, 331, 0),
  (4, 7, 8, 1259799, 0),
  (4, 7, 9, 20580, 0),
  (5, 7, 0, 6603, 0),
  (5, 7, 1, 403, 0),
  (5, 7, 2, 331, 0),
  (5, 7, 8, 20577, 0),
  (5, 7, 9, 7744, 0),
  (7, 7, 0, 6603, 0),
  (7, 7, 1, 403, 0),
  (7, 7, 2, 331, 0),
  (7, 7, 9, 20589, 0),
  (95, 7, 0, 6603, 0),
  (95, 7, 1, 403, 0),
  (95, 7, 2, 331, 0),
  (95, 7, 8, 1259705, 0),
  (95, 7, 9, 1259416, 0),
  (3, 8, 0, 6603, 0),
  (3, 8, 1, 133, 0),
  (3, 8, 2, 168, 0),
  (3, 8, 8, 20594, 0),
  (3, 8, 9, 2481, 0),
  (4, 8, 0, 6603, 0),
  (4, 8, 1, 133, 0),
  (4, 8, 2, 168, 0),
  (4, 8, 8, 1259799, 0),
  (4, 8, 9, 20580, 0),
  (6, 8, 0, 6603, 0),
  (6, 8, 1, 133, 0),
  (6, 8, 2, 168, 0),
  (6, 8, 8, 20549, 0),
  (6, 8, 9, 20552, 0),
  (96, 8, 0, 6603, 0),
  (96, 8, 1, 133, 0),
  (96, 8, 2, 168, 0),
  (96, 8, 8, 1259686, 0),
  (96, 8, 9, 1259416, 0),
  (3, 9, 0, 6603, 0),
  (3, 9, 1, 686, 0),
  (3, 9, 2, 687, 0),
  (3, 9, 8, 20594, 0),
  (3, 9, 9, 2481, 0),
  (4, 9, 0, 6603, 0),
  (4, 9, 1, 686, 0),
  (4, 9, 2, 687, 0),
  (4, 9, 8, 1259799, 0),
  (4, 9, 9, 20580, 0),
  (6, 9, 0, 6603, 0),
  (6, 9, 1, 686, 0),
  (6, 9, 2, 687, 0),
  (6, 9, 8, 20549, 0),
  (6, 9, 9, 20552, 0),
  (95, 9, 0, 6603, 0),
  (95, 9, 1, 686, 0),
  (95, 9, 2, 687, 0),
  (95, 9, 8, 1259705, 0),
  (95, 9, 9, 1259416, 0),
  (96, 9, 0, 6603, 0),
  (96, 9, 1, 686, 0),
  (96, 9, 2, 687, 0),
  (96, 9, 8, 1259686, 0),
  (96, 9, 9, 1259416, 0),
  (1, 11, 0, 6603, 0),
  (1, 11, 1, 5176, 0),
  (1, 11, 2, 5185, 0),
  (1, 11, 8, 1259718, 0),
  (1, 11, 9, 20600, 0),
  (2, 11, 0, 6603, 0),
  (2, 11, 1, 5176, 0),
  (2, 11, 2, 5185, 0),
  (2, 11, 9, 20572, 0),
  (3, 11, 0, 6603, 0),
  (3, 11, 1, 5176, 0),
  (3, 11, 2, 5185, 0),
  (3, 11, 8, 20594, 0),
  (3, 11, 9, 2481, 0),
  (5, 11, 0, 6603, 0),
  (5, 11, 1, 5176, 0),
  (5, 11, 2, 5185, 0),
  (5, 11, 8, 20577, 0),
  (5, 11, 9, 7744, 0),
  (7, 11, 0, 6603, 0),
  (7, 11, 1, 5176, 0),
  (7, 11, 2, 5185, 0),
  (7, 11, 9, 20589, 0),
  (8, 11, 0, 6603, 0),
  (8, 11, 1, 5176, 0),
  (8, 11, 2, 5185, 0),
  (8, 11, 8, 20554, 0),
  (8, 11, 9, 1260270, 0);

-- The client data only lets human and dwarf paladins start with Holy Light, and only undead can train it.
DELETE FROM playercreateinfo_spell_custom WHERE racemask = 12884902122 AND classmask = 2 AND Spell = 635;
INSERT INTO playercreateinfo_spell_custom (racemask, classmask, Spell, Note) VALUES (12884902122, 2, 635, 'Paladin - Holy Light for races the client data leaves out');
