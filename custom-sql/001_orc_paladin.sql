-- Test combination: orc paladin. Apply to the `world` database.
INSERT IGNORE INTO class_expansion_requirement (ClassID, RaceID, ActiveExpansionLevel, AccountExpansionLevel)
VALUES (2, 2, 0, 0);

-- Orc starting locations, copied from orc warrior.
INSERT IGNORE INTO playercreateinfo
  (race, class, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y,
   npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id)
SELECT race, 2, map, position_x, position_y, position_z, orientation, npe_map, npe_position_x, npe_position_y,
   npe_position_z, npe_orientation, npe_transport_guid, intro_movie_id, intro_scene_id, npe_intro_scene_id
FROM playercreateinfo WHERE race = 2 AND class = 1;

-- Auto Attack and paladin spells from human paladin, plus the orc racial Blood Fury.
INSERT IGNORE INTO playercreateinfo_action (race, class, button, action, type) VALUES
  (2, 2, 0, 6603, 0), (2, 2, 1, 20154, 0), (2, 2, 2, 635, 0), (2, 2, 9, 20572, 0);
